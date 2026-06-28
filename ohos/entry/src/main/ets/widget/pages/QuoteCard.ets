// 鸿蒙服务卡片 · 金句卡片页 (L21)
//
// 交互 (docs/adr/0002):
//   - 点正文 → postCardAction(router) 拉起 Folio 到屏保;
//   - 点"换一句" → postCardAction(message {action:'refresh'}) → 卡片在桌面
//     直接换下一句, 不打开 app (FormExtensionAbility.onFormEvent 处理)。
//   - 系统每 30min (form updateDuration) 也会自动推进 cursor 换句 (onUpdateForm)。
//
// UI 遵循 skill xiao-jinku-desig · 青纸 (Tea Paper) 主题:
//   bg-card #e2e6cf · ink-900 #1d2a1f (正文) · ink-500 #5e7263 (出处, 斜体)
//   accent leaf-500 #7ba05b (换一句) · 衬线字体, 出处右下角。

// 卡片数据由 FormExtensionAbility 通过 formBindingData 注入到 LocalStorage。
let storage = new LocalStorage();

@Entry(storage)
@Component
struct QuoteCard {
  // @LocalStorageProp 让卡片随 formProvider.updateForm 推送的数据刷新。
  // 默认值是数据桥未通时的静态降级文案 (决策四: 不白屏)。
  @LocalStorageProp('quoteText') quoteText: string = '把光收进来，从裂缝里。';
  @LocalStorageProp('quoteTag') quoteTag: string = '';
  // 播放模式 random/sequential —— 决定底部模式图标显示 shuffle 还是 list (Issue #13)。
  @LocalStorageProp('playMode') playMode: string = 'random';
  // 配色主题 paper/night/bamboo —— 跟随 app "小组件配色" 设置 (v0.20.0)。
  @LocalStorageProp('colorTheme') colorTheme: string = 'paper';

  // ── 主题色 (跟 skill colors_and_type.css 对齐, 卡片自洽的 3 套) ──
  private isDark(): boolean {
    return this.colorTheme === 'night';
  }

  private bg(): string {
    if (this.colorTheme === 'night') {
      return '#15211a';
    }
    if (this.colorTheme === 'bamboo') {
      return '#ece2c4';
    }
    return '#e8ead6';
  }

  private ink(): string {
    if (this.colorTheme === 'night') {
      return '#e6ebd9';
    }
    if (this.colorTheme === 'bamboo') {
      return '#33301c';
    }
    return '#1d2a1f';
  }

  private ink2(): string {
    if (this.colorTheme === 'night') {
      return '#8a9a82';
    }
    if (this.colorTheme === 'bamboo') {
      return '#7a6f4a';
    }
    return '#5e7263';
  }

  private accent(): string {
    if (this.colorTheme === 'night') {
      return '#9ec88a';
    }
    if (this.colorTheme === 'bamboo') {
      return '#9a7b3a';
    }
    return '#7ba05b';
  }

  private sealBg(): string {
    if (this.colorTheme === 'night') {
      return '#d4c47e';
    }
    return '#b07a2e';
  }

  private sealFg(): string {
    return this.isDark() ? '#15211a' : '#fbf7ec';
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
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
    });
  }

  build() {
    Column() {
      // 正文 —— 占满卡片绝大部分高度 (layoutWeight, flex 受限不压页脚)。
      // 字号随句长自适应, 超长省略号。点它拉起 app。
      Text(this.quoteText)
        .fontSize(this.quoteFontSize())
        .fontWeight(FontWeight.Medium)
        .fontColor(this.ink())
        .lineHeight(this.quoteFontSize() + 13)
        .maxLines(8)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .layoutWeight(1)
        .margin({ bottom: 10 })
        .onClick(() => {
          this.openApp();
        })

      // 页脚: 「金」朱印 + 出处 (左) + 模式/下一句 两个淡图标 (右)。
      Row() {
        Text('金')
          .width(20)
          .height(20)
          .borderRadius(5)
          .textAlign(TextAlign.Center)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.sealFg())
          .backgroundColor(this.sealBg())
          .margin({ right: 8 })
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

        // 模式切换 (随机=shuffle / 顺序=list), 桌面直接切, 不打开 app。
        Image(this.playMode === 'sequential'
          ? $r('app.media.ic_list')
          : $r('app.media.ic_shuffle'))
          .width(22)
          .height(22)
          .fillColor(this.ink2())
          .opacity(0.65)
          .margin({ right: 14 })
          .onClick(() => {
            postCardAction(this, {
              action: 'message',
              params: { event: 'mode' } as Record<string, string>,
            });
          })

        // 下一句 (skip-forward), 桌面直接换, 不打开 app。
        Image($r('app.media.ic_next'))
          .width(22)
          .height(22)
          .fillColor(this.accent())
          .onClick(() => {
            // params 用 "event" 不用 "action" (会被系统 action:'message' 覆盖)。
            postCardAction(this, {
              action: 'message',
              params: { event: 'refresh' } as Record<string, string>,
            });
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding(20)
    .backgroundColor(this.bg())
  }
}
