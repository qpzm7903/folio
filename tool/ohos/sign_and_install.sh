#!/usr/bin/env bash
# L20 里程碑③: 用 OpenHarmony SDK 自带的默认调试签名链给 hap 签名并装机。
#
# 关键发现: OpenHarmony SDK 的 toolchains/lib/OpenHarmony.p12 自带完整签名
# 私钥 (app + profile), 配合 hap-sign-tool.jar 可以全程离线签名, 不需要
# 华为开发者账号 / DevEco。详见 docs/wiki/ohos/03-签名装机.md。
#
# 注意: 纯血鸿蒙零售机 (Mate 80) 大概率拒装 OpenHarmony 自签 hap, 届时
# 转 AGC 官方调试证书 (同一把 hap-sign-tool, 换证书来源即可)。
#
# 用法:
#   bash tool/ohos/sign_and_install.sh            # 默认 selftest: OpenHarmony 自签
#                                                 #   (零售机会拒装, 仅验证工装连通)
#   SIGN_MODE=agc bash tool/ohos/sign_and_install.sh
#                                                 # AGC: 用 ohos/.signing/agc 下的
#                                                 #   folio.p12 + folio.cer + folio.p7b
# 前置: hap 已构建 (tool/ohos/build_hap.sh), Mate 80 已 USB 授权 (hdc list targets)。
set -euo pipefail

SIGN_MODE="${SIGN_MODE:-selftest}"

SDK_LIB="$HOME/sdks/ohos-sdk/sdk/20/toolchains/lib"
TOOLCHAINS="$HOME/sdks/ohos-sdk/sdk/20/toolchains"
SIGN_TOOL="$SDK_LIB/hap-sign-tool.jar"
P12="$SDK_LIB/OpenHarmony.p12"
PROFILE_CERT="$SDK_LIB/OpenHarmonyProfileDebug.pem"
PROFILE_TMPL="$SDK_LIB/UnsgnedDebugProfileTemplate.json"
STOREPWD="123456"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$REPO_ROOT/ohos/.signing"          # gitignore: 含设备 UDID, 不入库
UNSIGNED="$REPO_ROOT/ohos/entry/build/default/outputs/default/entry-default-unsigned.hap"
SIGNED="$WORK/entry-default-signed.hap"
BUNDLE="app.folio.quotes"

export PATH="$TOOLCHAINS:$PATH"
mkdir -p "$WORK"

echo "==> 取设备 UDID"
UDID="$(hdc shell bm get --udid 2>/dev/null | tr -d '\r' | tail -1 | tr -d ' ')"
[ -n "$UDID" ] || { echo "未取到 UDID, 检查 hdc list targets 是否已授权"; exit 1; }
echo "    UDID=$UDID"

if [ "$SIGN_MODE" = "agc" ]; then
  # AGC 模式: 用华为签发的证书/Profile + 自建密钥库, 直接签名装机。
  AGC="$WORK/agc"
  for f in folio.p12 folio.cer folio.p7b; do
    [ -f "$AGC/$f" ] || { echo "缺 $AGC/$f, 见 docs/wiki/ohos/03-签名装机.md §2.2"; exit 1; }
  done
  echo "==> AGC 签 hap"
  java -jar "$SIGN_TOOL" sign-app -mode localSign \
    -keyAlias "folio-ohos-key" -keyPwd "$STOREPWD" \
    -appCertFile "$AGC/folio.cer" -profileFile "$AGC/folio.p7b" \
    -inFile "$UNSIGNED" -signAlg SHA256withECDSA \
    -keystoreFile "$AGC/folio.p12" -keystorePwd "$STOREPWD" -outFile "$SIGNED"
  echo "==> 装机"; hdc install -r "$SIGNED"; echo "完成: $SIGNED"; exit 0
fi

echo "==> 导出 CA / RootCA 证书 + 拼 unsigned profile"
openssl pkcs12 -legacy -in "$P12" -passin pass:"$STOREPWD" -nokeys -out "$WORK/all_certs.pem" 2>/dev/null
BUNDLE="$BUNDLE" UDID="$UDID" PROFILE_TMPL="$PROFILE_TMPL" python3 - "$WORK" <<'PY'
import re,subprocess,sys,os,json
work=sys.argv[1]
certs=re.findall(r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----",
                 open(os.path.join(work,"all_certs.pem")).read(),re.S)
def cn(c):
    return subprocess.run(["openssl","x509","-noout","-subject"],input=c,
        capture_output=True,text=True).stdout.split("CN=")[-1].strip()
by={}
for c in certs: by.setdefault(cn(c),c)
open(os.path.join(work,"subca.cer"),"w").write(by["OpenHarmony Application CA"])
open(os.path.join(work,"rootca.cer"),"w").write(by["OpenHarmony Application Root CA"])
# unsigned profile: 注入 bundle / UDID / 刷新有效期; development-certificate
# 留空占位, 由后面 generate-app-cert 的叶证书在 sign-app 时校验。
tmpl=json.load(open(os.environ["PROFILE_TMPL"]))
tmpl["bundle-info"]["bundle-name"]=os.environ["BUNDLE"]
tmpl["bundle-info"]["development-certificate"]=by["OpenHarmony Application Release"]+"\n"
tmpl["debug-info"]["device-ids"]=[os.environ["UDID"]]
tmpl["validity"]={"not-before":1610519532,"not-after":1925879532}  # ~2031
json.dump(tmpl,open(os.path.join(work,"unsigned_profile.json"),"w"),indent=2)
print("    subca.cer + rootca.cer + unsigned_profile.json 就绪")
PY

echo "==> 现签 app 证书链 (用 p12 里的 Application CA 私钥)"
java -jar "$SIGN_TOOL" generate-app-cert \
  -keyAlias "openharmony application release" -keyPwd "$STOREPWD" \
  -issuer "C=CN,O=OpenHarmony,OU=OpenHarmony Team,CN=OpenHarmony Application CA" \
  -issuerKeyAlias "openharmony application ca" -issuerKeyPwd "$STOREPWD" \
  -subject "C=CN,O=OpenHarmony,OU=OpenHarmony Team,CN=OpenHarmony Application Release" \
  -validity 3650 -signAlg SHA256withECDSA \
  -rootCaCertFile "$WORK/rootca.cer" -subCaCertFile "$WORK/subca.cer" \
  -keystoreFile "$P12" -keystorePwd "$STOREPWD" \
  -outForm certChain -outFile "$WORK/app_cert_chain.pem"

echo "==> 签 profile (p7b)"
java -jar "$SIGN_TOOL" sign-profile \
  -mode localSign \
  -keyAlias "openharmony application profile debug" \
  -keyPwd "$STOREPWD" \
  -profileCertFile "$PROFILE_CERT" \
  -inFile "$WORK/unsigned_profile.json" \
  -signAlg SHA256withECDSA \
  -keystoreFile "$P12" \
  -keystorePwd "$STOREPWD" \
  -outFile "$WORK/folio_debug.p7b"

echo "==> 签 hap"
java -jar "$SIGN_TOOL" sign-app \
  -mode localSign \
  -keyAlias "openharmony application release" \
  -keyPwd "$STOREPWD" \
  -appCertFile "$WORK/app_cert_chain.pem" \
  -profileFile "$WORK/folio_debug.p7b" \
  -inFile "$UNSIGNED" \
  -signAlg SHA256withECDSA \
  -keystoreFile "$P12" \
  -keystorePwd "$STOREPWD" \
  -outFile "$SIGNED"

echo "==> 装机"
hdc shell param set persist.bms.ohCert.verify true 2>/dev/null || true
hdc install -r "$SIGNED"
echo "完成: $SIGNED"
