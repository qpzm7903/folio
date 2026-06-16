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

  build() {
    Column() {
      // 正文金句 —— 衬线、深墨绿、行距宽松。点它拉起 app。
      Text(this.quoteText)
        .fontSize(16)
        .fontWeight(FontWeight.Normal)
        .fontColor('#1d2a1f')
        .lineHeight(28)
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .onClick(() => {
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
          });
        })

      Blank()

      // 底部行: 出处 (左, 斜体淡墨) + "换一句" 按钮 (右, accent)。
      Row() {
        if (this.quoteTag.length > 0) {
          Text('— ' + this.quoteTag)
            .fontSize(12)
            .fontStyle(FontStyle.Italic)
            .fontColor('#5e7263')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        } else {
          Blank().layoutWeight(1)
        }

        // 模式切换 —— 音乐播放器式图标 (随机=shuffle / 顺序=list), 不打开 app。
        Image(this.playMode === 'sequential'
          ? $r('app.media.ic_list')
          : $r('app.media.ic_shuffle'))
          .width(26)
          .height(26)
          .padding(8)
          .margin({ right: 8 })
          .borderRadius(14)
          .backgroundColor('#f7f8ed')
          .onClick(() => {
            postCardAction(this, {
              action: 'message',
              params: { event: 'mode' } as Record<string, string>,
            });
          })

        // 下一句 —— 在桌面直接换下一句, 不打开 app (skip-forward 图标)。
        Image($r('app.media.ic_next'))
          .width(26)
          .height(26)
          .padding(8)
          .borderRadius(14)
          .backgroundColor('#f7f8ed')
          .onClick(() => {
            // 注意: params 别用 "action" 当 key, 会跟系统追加的 action:'message'
            // 撞名被覆盖。用 "event": refresh=下一句 / mode=切模式。
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
    .padding(16)
    .backgroundColor('#e2e6cf')
  }
}
