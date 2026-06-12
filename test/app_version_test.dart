import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_version.dart';

/// 这个测试锁住 [kAppVersion] 跟 `pubspec.yaml` 的 `version:` 字段一致。
///
/// 漏改任一处都会让 settings 屏 footer 显示错误版本号 (Issue #9 的根因)。
void main() {
  group('kAppVersion', () {
    test('与 pubspec.yaml 的 version 字段一致', () {
      final File pubspec = File('pubspec.yaml');
      expect(pubspec.existsSync(), isTrue, reason: '测试必须在仓库根目录跑');
      final List<String> lines = pubspec.readAsLinesSync();
      // pubspec 里形如 `version: 0.15.1+40`, 取冒号后的 MAJOR.MINOR.PATCH 部分
      final String line = lines.firstWhere(
        (String l) => l.startsWith('version:'),
        orElse: () => '',
      );
      expect(line, isNotEmpty, reason: 'pubspec.yaml 缺 version 字段');
      final String raw = line.substring('version:'.length).trim();
      final String semver = raw.split('+').first.trim();
      expect(
        semver,
        kAppVersion,
        reason: 'lib/core/app_version.dart 的 kAppVersion ($kAppVersion) '
            '与 pubspec.yaml 的 version ($semver) 不一致, '
            '必须两处同步 bump (Issue #9 根因防回归)',
      );
    });

    test('格式为 MAJOR.MINOR.PATCH', () {
      final RegExp semverRe = RegExp(r'^\d+\.\d+\.\d+$');
      expect(semverRe.hasMatch(kAppVersion), isTrue);
    });
  });
}
