// 鸿蒙服务卡片 · FormExtensionAbility (L21 里程碑②③)
//
// 数据流 (docs/adr/0002): Dart OhosWidgetService → app.folio/ohos_widget
// channel → EntryAbility 写 preferences(folio_widget) → 本 ability 读 timeline,
// 按 cursor 取一句渲染。
//
// 三种换句路径都推进 cursor:
//   - onUpdateForm: 系统定时 (form_config updateDuration=30min) 自动换句;
//   - onFormEvent : 用户点卡片上的"换一句"按钮立即换句 (不打开 app);
// 都复用 advanceCursor() + formProvider.updateForm。
//
// 降级 (决策四): preferences 无数据 / 解析失败 → 回落静态种子金句, 不白屏。
// import 路径: OpenHarmony 6 fork 上 @kit.FormKit / @kit.ArkData 已验证可用。

import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const WIDGET_STORE: string = 'folio_widget';
const KEY_TIMELINE: string = 'widgetTimeline';
const KEY_CURSOR: string = 'widgetTimelineCursor';

const SEED_TEXT: string = '把光收进来，从裂缝里。';
const SEED_TAG: string = '种子';

// 跟 Dart WidgetTimeline.serialize 的紧凑 JSON 字段对应: q=正文, s=出处。
interface QuoteItem {
  q: string;
  s: string;
}

interface CardData {
  quoteText: string;
  quoteTag: string;
}

function seed(): CardData {
  return { quoteText: SEED_TEXT, quoteTag: SEED_TAG };
}

function parseTimeline(json: string): QuoteItem[] {
  if (json.length === 0) {
    return [];
  }
  try {
    const list = JSON.parse(json) as QuoteItem[];
    return (list && list.length > 0) ? list : [];
  } catch (err) {
    return [];
  }
}

// 读 preferences 里 timeline[cursor] 一句; 任何缺失/异常回落种子句。
function readCard(context: common.ExtensionContext): CardData {
  try {
    const store = preferences.getPreferencesSync(context, { name: WIDGET_STORE });
    const list = parseTimeline(store.getSync(KEY_TIMELINE, '') as string);
    if (list.length === 0) {
      return seed();
    }
    const raw = parseInt(store.getSync(KEY_CURSOR, '0') as string, 10);
    const cursor = isNaN(raw) ? 0 : raw;
    const idx = ((cursor % list.length) + list.length) % list.length;
    const item = list[idx];
    return { quoteText: item.q ?? SEED_TEXT, quoteTag: item.s ?? '' };
  } catch (err) {
    return seed();
  }
}

// cursor +1 取模写回 preferences (timeline 为空时不动)。
function advanceCursor(context: common.ExtensionContext): void {
  try {
    const store = preferences.getPreferencesSync(context, { name: WIDGET_STORE });
    const list = parseTimeline(store.getSync(KEY_TIMELINE, '') as string);
    if (list.length === 0) {
      return;
    }
    const raw = parseInt(store.getSync(KEY_CURSOR, '0') as string, 10);
    const cur = isNaN(raw) ? 0 : raw;
    const next = (cur + 1) % list.length;
    store.putSync(KEY_CURSOR, next.toString());
    store.flush();
  } catch (err) {
    // 静默: cursor 不动, 卡片保留当前句。
  }
}

export default class QuoteFormAbility extends FormExtensionAbility {
  // 桌面新增卡片时调用 —— 返回首帧绑定数据。
  onAddForm(want: Want): formBindingData.FormBindingData {
    const ctx = this.context as common.ExtensionContext;
    return formBindingData.createFormBindingData(readCard(ctx));
  }

  // 系统定时刷新 (form_config updateDuration=30min): 推进 cursor 再渲染,
  // 对齐 L18 Android 的 cursor 自动换句。
  onUpdateForm(formId: string): void {
    const ctx = this.context as common.ExtensionContext;
    advanceCursor(ctx);
    this.render(ctx, formId);
  }

  // 卡片上的交互按钮 (postCardAction message) → 这里收到。"换一句" 让用户
  // 在桌面立即换下一句, 不打开 app。message 是 params 的 JSON 串。
  onFormEvent(formId: string, message: string): void {
    const ctx = this.context as common.ExtensionContext;
    let action = '';
    try {
      const obj = JSON.parse(message) as Record<string, string>;
      action = obj.action ?? '';
    } catch (err) {
      action = '';
    }
    if (action === 'refresh') {
      advanceCursor(ctx);
      this.render(ctx, formId);
    }
  }

  private render(ctx: common.ExtensionContext, formId: string): void {
    try {
      const data = formBindingData.createFormBindingData(readCard(ctx));
      formProvider.updateForm(formId, data);
    } catch (err) {
      // 静默: 卡片保留上一帧。
    }
  }

  onRemoveForm(formId: string): void {
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
  }
}
