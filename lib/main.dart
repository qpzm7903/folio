import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/logger.dart';
import 'data/quote_repository.dart';
import 'presentation/providers.dart';
import 'presentation/widget_sync_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init();
  await initializeDateFormatting('zh_CN');

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final QuoteRepository quoteRepo = await buildQuoteRepository();

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        quoteRepositoryProvider.overrideWithValue(quoteRepo),
      ],
      child: const WidgetSyncBridge(child: FolioApp()),
    ),
  );
}
