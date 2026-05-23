import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/bootstrap.dart';
import 'presentation/widget_sync_bridge.dart';

Future<void> main() async {
  final List<Override> overrides = await Bootstrap.initialize();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const WidgetSyncBridge(child: FolioApp()),
    ),
  );
}
