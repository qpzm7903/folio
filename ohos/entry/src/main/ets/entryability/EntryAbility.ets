
import { FlutterAbility, FlutterEngine, MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// L21 里程碑② 数据桥: Dart (OhosWidgetService) 经这条自写 channel 把 timeline
// 推过来, 写进**应用级** preferences (getApplicationContext, 保证跟 FormExtension-
// Ability 跨进程读同一个 store) 供 QuoteFormAbility 读 (设计见 docs/adr/0002)。
// channel 是 Flutter 引擎核心能力、preferences 是 ArkTS 系统 API, 都不走受阻的
// 联邦插件 (上游 #1)。
const WIDGET_CHANNEL: string = 'app.folio/ohos_widget';
const WIDGET_STORE: string = 'folio_widget';
const KEY_TIMELINE: string = 'widgetTimeline';
const KEY_CURSOR: string = 'widgetTimelineCursor';
const KEY_COLOR: string = 'widgetColorTheme';
const LOG_TAG: string = 'FolioWidget';
const LOG_DOMAIN: number = 0xF010;

class WidgetChannelHandler implements MethodCallHandler {
  private context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method !== 'syncTimeline') {
      result.notImplemented();
      return;
    }
    try {
      const timeline: string = (call.argument(KEY_TIMELINE) as string) ?? '';
      const cursor: string = (call.argument(KEY_CURSOR) as string) ?? '0';
      const color: string = (call.argument(KEY_COLOR) as string) ?? '';
      const store = preferences.getPreferencesSync(this.context, { name: WIDGET_STORE });
      store.putSync(KEY_TIMELINE, timeline);
      store.putSync(KEY_CURSOR, cursor);
      if (color.length > 0) {
        store.putSync(KEY_COLOR, color);
      }
      store.flush();
      hilog.info(LOG_DOMAIN, LOG_TAG, 'channel write ok, timelineLen=%{public}d', timeline.length);
      result.success(null);
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'channel write failed: %{public}s', JSON.stringify(err) ?? '');
      result.error('ohos_widget_write_failed', 'write widget preferences failed', null);
    }
  }
}

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)

    // 用应用级 context, 保证 UIAbility 写的 store 跟 FormExtensionAbility 读的
    // 是同一个 (二者是不同进程, 用各自 ability context 可能落到不同目录)。
    const appCtx: common.Context = this.context.getApplicationContext();
    const channel = new MethodChannel(flutterEngine.getDartExecutor(), WIDGET_CHANNEL);
    channel.setMethodCallHandler(new WidgetChannelHandler(appCtx));
  }
}
