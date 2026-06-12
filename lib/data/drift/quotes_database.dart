import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../quote.dart';

part 'quotes_database.g.dart';

/// 表声明。drift 生成的 row class 用 `@DataClassName('QuoteRow')`
/// 避开跟业务 [Quote] (plain Dart class) 重名。
///
/// 注意: column getter 名不能跟 [Table] 父类工厂方法 (`text()` /
/// `integer()` / `bool()` / `dateTime()` 等) 重名, 所以业务的 `text`
/// 字段在 SQLite 里存为 `content` 列, repo 层做名字映射。
@DataClassName('QuoteRow')
class Quotes extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get tag => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => <Column>{id};
}

@DriftDatabase(tables: <Type>[Quotes])
class QuotesDatabase extends _$QuotesDatabase {
  QuotesDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// 默认连接 —— `getApplicationSupportDirectory()/quotes.sqlite`。
  ///
  /// Android 部分 ROM 上 `getApplicationSupportDirectory()` 返回的路径
  /// 在首次冷启动时尚未由系统创建, drift 在 isolate 里 `open(File)` 会因父
  /// 目录不存在直接抛 SQLiteException → 进程闪退 (#1)。所以这里显式
  /// `createSync(recursive: true)`。
  static QueryExecutor _openDefault() {
    return LazyDatabase(() async {
      final Directory dir = await getApplicationSupportDirectory();
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final File f = File('${dir.path}/quotes.sqlite');
      return NativeDatabase.createInBackground(f);
    });
  }

  factory QuotesDatabase.openDefault() => QuotesDatabase(_openDefault());

  /// 测试用 in-memory 实例。
  factory QuotesDatabase.memory() => QuotesDatabase(NativeDatabase.memory());

  Future<List<Quote>> loadAll() async {
    final List<QuoteRow> rows = await (select(quotes)
          ..orderBy(<OrderClauseGenerator<$QuotesTable>>[
            (Quotes t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
    return <Quote>[
      for (final QuoteRow r in rows)
        Quote(id: r.id, text: r.content, tag: r.tag, createdAt: r.createdAt),
    ];
  }

  Future<void> saveAll(List<Quote> qs) async {
    await transaction(() async {
      await delete(quotes).go();
      await batch((Batch b) {
        b.insertAll(quotes, <Insertable<QuoteRow>>[
          for (final Quote q in qs)
            QuotesCompanion.insert(
              id: q.id,
              content: q.text,
              tag: Value<String>(q.tag),
              createdAt: q.createdAt,
            ),
        ]);
      });
    });
  }
}
