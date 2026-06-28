// 鸿蒙服务卡片 · FormExtensionAbility (L21 里程碑②③)
//
// 数据流 (docs/adr/0002): Dart OhosWidgetService → app.folio/ohos_widget
// channel → EntryAbility 写**应用级** preferences(folio_widget) → 本 ability
// (另一个进程) 读 timeline, 按 cursor 取一句渲染。
//
// 跨进程要点: FormExtensionAbility 与 UIAbility 是不同进程, 用
// getApplicationContext() 拿同一个 store; 每次读前 removePreferencesFromCacheSync
// 强制从磁盘重载, 避免读到本进程的旧缓存 (拿不到 EntryAbility 刚写的数据)。
//
// 三种换句路径都推进 cursor: onUpdateForm(系统 30min 定时) / onFormEvent
// (卡片"换一句"按钮, 不打开 app) / app 前台数据桥推送。
// 降级 (决策四): preferences 无数据 / 解析失败 → 回落静态种子金句, 不白屏。

import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const WIDGET_STORE: string = 'folio_widget';
const KEY_TIMELINE: string = 'widgetTimeline';
const KEY_CURSOR: string = 'widgetTimelineCursor';
const KEY_MODE: string = 'widgetPlayMode';
const KEY_COLOR: string = 'widgetColorTheme';
const MODE_SEQUENTIAL: string = 'sequential';
const MODE_RANDOM: string = 'random';
const LOG_TAG: string = 'FolioWidget';
const LOG_DOMAIN: number = 0xF010;

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
  playMode: string;
  colorTheme: string;
}

function seed(mode: string = MODE_RANDOM, color: string = 'paper'): CardData {
  return {
    quoteText: SEED_TEXT,
    quoteTag: SEED_TAG,
    playMode: mode,
    colorTheme: color,
  };
}

function readMode(store: preferences.Preferences): string {
  const m = store.getSync(KEY_MODE, MODE_RANDOM) as string;
  return m === MODE_SEQUENTIAL ? MODE_SEQUENTIAL : MODE_RANDOM;
}

function readColor(store: preferences.Preferences): string {
  const c = store.getSync(KEY_COLOR, 'paper') as string;
  return (c === 'night' || c === 'bamboo') ? c : 'paper';
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

// 随机取一个 != current 的下标 (整库随机, Issue #11/#13 随机模式)。
function randomIndex(len: number, current: number): number {
  if (len <= 1) {
    return 0;
  }
  let r = Math.floor(Math.random() * len);
  if (r === current) {
    r = (r + 1) % len;
  }
  return r;
}

// 读 timeline[cursor] 一句; advance=true 时按 mode 推进 cursor 写回:
// 顺序 = cursor+1 取模; 随机 = 整库随机下标。每次都 removeFromCache 强制读磁盘
// 最新值 (跨进程)。缺失/异常回落种子句。
function nextCard(context: common.Context, advance: boolean): CardData {
  try {
    preferences.removePreferencesFromCacheSync(context, { name: WIDGET_STORE });
    const store = preferences.getPreferencesSync(context, { name: WIDGET_STORE });
    const mode = readMode(store);
    const color = readColor(store);
    const list = parseTimeline(store.getSync(KEY_TIMELINE, '') as string);
    if (list.length === 0) {
      hilog.info(LOG_DOMAIN, LOG_TAG, 'form read: timeline empty -> seed');
      return seed(mode, color);
    }
    const raw = parseInt(store.getSync(KEY_CURSOR, '0') as string, 10);
    let cursor = isNaN(raw) ? 0 : raw;
    if (advance) {
      cursor = mode === MODE_SEQUENTIAL
        ? (cursor + 1) % list.length
        : randomIndex(list.length, cursor);
      store.putSync(KEY_CURSOR, cursor.toString());
      store.flush();
    }
    const idx = ((cursor % list.length) + list.length) % list.length;
    const item = list[idx];
    hilog.info(LOG_DOMAIN, LOG_TAG, 'form card: len=%{public}d cursor=%{public}d mode=%{public}s advance=%{public}s',
      list.length, idx, mode, String(advance));
    return {
      quoteText: item.q ?? SEED_TEXT,
      quoteTag: item.s ?? '',
      playMode: mode,
      colorTheme: color,
    };
  } catch (err) {
    hilog.error(LOG_DOMAIN, LOG_TAG, 'form read failed: %{public}s', JSON.stringify(err) ?? '');
    return seed();
  }
}

// 切换 random <-> sequential 写回, 展示当前 cursor 句 (不前进), 仅更新模式图标。
function toggleMode(context: common.Context): CardData {
  try {
    preferences.removePreferencesFromCacheSync(context, { name: WIDGET_STORE });
    const store = preferences.getPreferencesSync(context, { name: WIDGET_STORE });
    const next = readMode(store) === MODE_SEQUENTIAL ? MODE_RANDOM : MODE_SEQUENTIAL;
    store.putSync(KEY_MODE, next);
    store.flush();
    const color = readColor(store);
    const list = parseTimeline(store.getSync(KEY_TIMELINE, '') as string);
    if (list.length === 0) {
      return seed(next, color);
    }
    const raw = parseInt(store.getSync(KEY_CURSOR, '0') as string, 10);
    const cursor = isNaN(raw) ? 0 : raw;
    const idx = ((cursor % list.length) + list.length) % list.length;
    const item = list[idx];
    hilog.info(LOG_DOMAIN, LOG_TAG, 'form mode toggled -> %{public}s', next);
    return {
      quoteText: item.q ?? SEED_TEXT,
      quoteTag: item.s ?? '',
      playMode: next,
      colorTheme: color,
    };
  } catch (err) {
    hilog.error(LOG_DOMAIN, LOG_TAG, 'form toggle mode failed: %{public}s', JSON.stringify(err) ?? '');
    return seed();
  }
}

export default class QuoteFormAbility extends FormExtensionAbility {
  private appCtx(): common.Context {
    return this.context.getApplicationContext();
  }

  // 桌面新增卡片时调用 —— 返回首帧绑定数据 (不推进 cursor)。
  onAddForm(want: Want): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(nextCard(this.appCtx(), false));
  }

  // 系统定时刷新 (form_config updateDuration=30min): 推进 cursor 换句。
  onUpdateForm(formId: string): void {
    this.render(formId, nextCard(this.appCtx(), true));
  }

  // 卡片"换一句"按钮 (postCardAction message) → 这里收到。立即换下一句, 不打开 app。
  //
  // 坑: postCardAction 会把 params 平铺到顶层 message, 且系统会追加自己的
  // "action":"message" —— 若 params 用 "action" 当 key 会被覆盖 (JSON 重复 key
  // 后者胜), 解析不到。本卡片只有"换一句"一个消息事件, 故收到任何 onFormEvent
  // 都换下一句, 不依赖具体字段, 最稳。
  onFormEvent(formId: string, message: string): void {
    hilog.info(LOG_DOMAIN, LOG_TAG, 'onFormEvent msg=%{public}s', message ?? '');
    // event=mode → 切随机/顺序模式 (不前进); 否则 (refresh) → 下一句。
    const isMode = (message ?? '').indexOf('mode') >= 0;
    this.render(
      formId,
      isMode ? toggleMode(this.appCtx()) : nextCard(this.appCtx(), true),
    );
  }

  private render(formId: string, data: CardData): void {
    try {
      formProvider.updateForm(formId, formBindingData.createFormBindingData(data));
    } catch (err) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'updateForm failed: %{public}s', JSON.stringify(err) ?? '');
    }
  }

  onRemoveForm(formId: string): void {
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
  }
}
