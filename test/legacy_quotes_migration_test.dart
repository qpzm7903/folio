import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:folio/data/legacy_quotes_migration.dart';
import 'package:folio/data/quote_codec.dart';
import 'package:folio/data/quote.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kPrefsKey = 'folio.quotes.v1';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final Directory root;

  @override
  Future<String?> getApplicationSupportPath() async => root.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('folio_legacy_test_');
    PathProviderPlatform.instance = _FakePathProvider(tmp);
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  Quote mk(String id, String text) =>
      Quote(id: id, text: text, tag: '', createdAt: DateTime(2026, 1, 1));

  test('quotes.json 不存在 → no-op', () async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await LegacyQuotesMigration(prefs: p, prefsKey: _kPrefsKey).run();
    expect(p.getString(_kPrefsKey), isNull);
  });

  test('quotes.json 存在 + prefs 空 → 导入 + rename 备份', () async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final List<Quote> seed = <Quote>[mk('a', '春风'), mk('b', '秋月')];
    final File legacy = File('${tmp.path}/quotes.json');
    await legacy.writeAsString(QuoteCodec.encode(seed));

    await LegacyQuotesMigration(prefs: p, prefsKey: _kPrefsKey).run();

    final String? written = p.getString(_kPrefsKey);
    expect(written, isNotNull);
    final List<Quote>? decoded = QuoteCodec.tryDecode(written!, context: '');
    expect(decoded?.map((Quote q) => q.id), <String>['a', 'b']);
    expect(legacy.existsSync(), isFalse);
    final List<FileSystemEntity> entries = tmp.listSync();
    expect(
      entries.any((FileSystemEntity e) => e.path.contains('migrated-')),
      isTrue,
    );
  });

  test('prefs 已有数据 → 不动 legacy 文件', () async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setString(_kPrefsKey, QuoteCodec.encode(<Quote>[mk('x', '已有')]));
    final File legacy = File('${tmp.path}/quotes.json');
    await legacy.writeAsString(QuoteCodec.encode(<Quote>[mk('a', '旧')]));

    await LegacyQuotesMigration(prefs: p, prefsKey: _kPrefsKey).run();

    expect(legacy.existsSync(), isTrue, reason: 'legacy 应未被 rename');
    final List<Quote>? cur = QuoteCodec.tryDecode(
      p.getString(_kPrefsKey)!,
      context: '',
    );
    expect(cur?.first.id, 'x', reason: 'prefs 不应被覆盖');
  });

  test('quotes.json 内容损坏 → swallow + 不污染 prefs', () async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    final File legacy = File('${tmp.path}/quotes.json');
    await legacy.writeAsString('not valid json {{{');

    await LegacyQuotesMigration(prefs: p, prefsKey: _kPrefsKey).run();

    expect(p.getString(_kPrefsKey), isNull);
    expect(legacy.existsSync(), isTrue);
  });
}
