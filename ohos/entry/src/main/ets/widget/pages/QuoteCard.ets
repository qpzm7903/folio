// 鸿蒙服务卡片 · 金句卡片页 (L21)
//
// 交互 (docs/adr/0002):
//   - 点正文 → postCardAction(router) 拉起 Folio 到屏保;
//   - 点"换一句" → postCardAction(message) → 卡片在桌面直接换下一句,
//     不打开 app (FormExtensionAbility.onFormEvent 处理)。
//   - 系统每 30min (form updateDuration) 也会自动推进 cursor 换句 (onUpdateForm)。
//
// UI 遵循 skill xiao-jinku-desig · 六主题配色。
// v0.21.1: 去掉「金」朱印 + 模式切换按钮 (模式在 app「我的」里调)。
// v0.21.2: 墨色调暖 + 行距加大 + 内边距加大, 接近西窗烛/句子控的舒服感。
//   衬线字体待更高 API SDK (getLocalInstance 需要 API 22+, 当前 SDK 20 不含)。

// 卡片数据由 FormExtensionAbility 通过 formBindingData 注入到 LocalStorage。
let storage = new LocalStorage();

// postCardAction 的参数需要显式接口类型 (arkts-no-untyped-obj-literals)。
interface CardRouterAction {
  action: string;
  abilityName: string;
}

interface CardMessageAction {
  action: string;
  event: string;
}

@Entry(storage)
@Component
struct QuoteCard {
  // @LocalStorageProp 让卡片随 formProvider.updateForm 推送的数据刷新。
  // 默认值是数据桥未通时的静态降级文案 (决策四: 不白屏)。
  @LocalStorageProp('quoteText') quoteText: string = '把光收进来，从裂缝里。';
  @LocalStorageProp('quoteTag') quoteTag: string = '';
  // 配色主题 paper/celadon/moonwhite/cinnabar/night/dai —— 跟随 app "小组件配色" 设置 (v0.21.0 六主题)。
  @LocalStorageProp('colorTheme') colorTheme: string = 'paper';

  // ── 主题色 (跟 skill colors_and_type.css 六主题对齐, 卡片自洽 6 套) ──
  // v0.21.2: ink 调暖 (从纯墨绿/墨黑改成带暖灰倾向, 接近西窗烛/句子控的墨色)。
  private bg(): string {
    switch (this.colorTheme) {
      case 'celadon':   return '#e1ebe4';
      case 'moonwhite': return '#e6e8f1';
      case 'cinnabar':  return '#f0e1d0';
      case 'night':     return '#0e1612';
      case 'dai':       return '#11151e';
      default:          return '#eef0df'; // paper
    }
  }

  private ink(): string {
    switch (this.colorTheme) {
      case 'celadon':   return '#2a3a37';
      case 'moonwhite': return '#2a3050';
      case 'cinnabar':  return '#3a2418';
      case 'night':     return '#e6ebd9';
      case 'dai':       return '#e6e9f2';
      default:          return '#2a3328'; // paper (暖墨, 原 #1d2a1f)
    }
  }

  private ink2(): string {
    switch (this.colorTheme) {
      case 'celadon':   return '#5b716c';
      case 'moonwhite': return '#5d6783';
      case 'cinnabar':  return '#7c5848';
      case 'night':     return '#8a9a82';
      case 'dai':       return '#828ba6';
      default:          return '#5e7263'; // paper
    }
  }

  private accent(): string {
    switch (this.colorTheme) {
      case 'celadon':   return '#5f968c';
      case 'moonwhite': return '#6f84bb';
      case 'cinnabar':  return '#c14a30';
      case 'night':     return '#9ec88a';
      case 'dai':       return '#88a4cc';
      default:          return '#7ba05b'; // paper
    }
  }

  // 字号随句长自适应 (2x2 卡片空间有限, 长句缩小避免溢出)。
  private quoteFontSize(): number {
    const n = this.quoteText.length;
    if (n <= 12) {
      return 23;
    }
    if (n <= 22) {
      return 19;
    }
    if (n <= 38) {
      return 16;
    }
    return 14;
  }

  private openApp(): void {
    const routerAction: CardRouterAction = {
      action: 'router',
      abilityName: 'EntryAbility',
    };
    postCardAction(this, routerAction);
  }

  build() {
    Column() {
      // 正文 —— 占满卡片绝大部分高度 (layoutWeight, flex 受限不压页脚)。
      // 字号随句长自适应, 超长省略号。点它拉起 app。
      // v0.21.2: 行距加大 (fontSize+18, 原 +13) 让文字更"安住"。
      Text(this.quoteText)
        .fontSize(this.quoteFontSize())
        .fontWeight(FontWeight.Medium)
        .fontColor(this.ink())
        .lineHeight(this.quoteFontSize() + 18)
        .maxLines(8)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .layoutWeight(1)
        .margin({ bottom: 12 })
        .onClick(() => {
          this.openApp();
        })

      // 页脚: 出处 (左, 占满) + 下一句按钮 (右)。v0.21.1 起去掉「金」朱印
      // 和模式切换按钮 (模式在 app「我的」里调, 卡片上只留换句)。
      Row() {
        if (this.quoteTag.length > 0) {
          Text(this.quoteTag)
            .fontSize(13)
            .fontStyle(FontStyle.Italic)
            .fontColor(this.ink2())
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        } else {
          Blank().layoutWeight(1)
        }

        // 下一句 (skip-forward), 桌面直接换, 不打开 app。
        Image($r('app.media.ic_next'))
          .width(22)
          .height(22)
          .fillColor(this.accent())
          .onClick(() => {
            const msgAction: CardMessageAction = {
              action: 'message',
              event: 'refresh',
            };
            postCardAction(this, msgAction);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding(24)
    .backgroundColor(this.bg())
  }
}
