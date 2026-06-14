// 鸿蒙服务卡片 · FormExtensionAbility (L21 里程碑① 静态 spike)
//
// ⚠ 未真机验证: 真机 (hdc) 当前未连接。本文件按 HarmonyOS form 扩展能力约定
//   编写, 里程碑① 只做"注入一句静态种子金句"。数据桥 (里程碑②) 接通后,
//   onAddForm / onUpdateForm 改为从 @ohos.data.preferences 读 widgetTimeline
//   (见 docs/adr/0002-ohos-service-card.md 决策一/二)。
//
// import 路径风险: OpenHarmony 6 / HarmonyOS 6 上 form 能力的规范导入可能是
//   '@kit.FormKit' (HarmonyOS NEXT) 或 '@ohos.app.form.*' (OpenHarmony)。
//   本程无真机, 先用 @kit.FormKit, 真机首编若报 Cannot find module 再换,
//   并把结论回填 wiki 04。

import { formBindingData, FormExtensionAbility } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

// 数据桥未通时的种子金句 (决策四: 卡片永不白屏)。
const SEED_TEXT: string = '把光收进来，从裂缝里。';
const SEED_TAG: string = '种子';

export default class QuoteFormAbility extends FormExtensionAbility {
  // 桌面新增卡片时调用 —— 返回首帧绑定数据。
  onAddForm(want: Want): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData({
      quoteText: SEED_TEXT,
      quoteTag: SEED_TAG,
    });
  }

  // 系统定时刷新 (form_config updateDuration) 或可见性变化时调用。
  // 里程碑① 仍回灌种子金句; 里程碑③ 在此读 cursor → +1 取模 → 写回 →
  // formProvider.updateForm 推进 timeline (对齐 L18 Android cursor 机制)。
  onUpdateForm(formId: string): void {
    // 里程碑② 前无数据可读, 留空 (系统会保留上一帧)。
  }

  // 卡片被移除 —— 里程碑② 起在此清理该 formId 关联的 preferences 状态。
  onRemoveForm(formId: string): void {
  }

  // 卡片可见性变化 —— 预留, 里程碑③ 可用来按需触发一次 updateForm。
  onChangeFormVisibility(newStatus: Record<string, number>): void {
  }
}
