
import { FlutterAbility, FlutterEngine, MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

// L21 里程碑② 数据桥: Dart (OhosWidgetService) 经这条自写 channel 把 timeline
// 推过来, 写进应用沙箱 preferences 供 QuoteFormAbility 读 (设计见 docs/adr/0002)。
// channel 是 Flutter 引擎核心能力、preferences 是 ArkTS 系统 API, 两者都不走
// 受阻的联邦插件 (上游 #1)。
const WIDGET_CHANNEL: string = 'app.folio/ohos_widget';
const WIDGET_STORE: string = 'folio_widget';
const KEY_TIMELINE: string = 'widgetTimeline';
const KEY_CURSOR: string = 'widgetTimelineCursor';
const KEY_COLOR: string = 'widgetColorTheme';

class WidgetChannelHandler implements MethodCallHandler {
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
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
      result.success(null);
    } catch (err) {
      result.error('ohos_widget_write_failed', 'write widget preferences failed', null);
    }
  }
}

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)

    const channel = new MethodChannel(flutterEngine.getDartExecutor(), WIDGET_CHANNEL);
    channel.setMethodCallHandler(new WidgetChannelHandler(this.context as common.UIAbilityContext));
  }
}
