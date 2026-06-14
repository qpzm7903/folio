// 鸿蒙服务卡片 · 金句卡片页 (L21 里程碑① 静态 spike)
//
// ⚠ 未真机验证: 真机 (hdc) 当前未连接, 本文件按 HarmonyOS ArkTS form 卡片
//   约定编写, 仅作为"卡片能加到桌面 + 显示一句金句"的可验证起点。验证步骤见
//   docs/wiki/ohos/04-服务卡片.md。数据桥 (里程碑②) 接通前, 卡片显示由
//   FormExtensionAbility.onAddForm 注入的种子金句。
//
// UI 遵循 skill xiao-jinku-desig · 青纸 (Tea Paper) 主题:
//   bg-card #e2e6cf · ink-900 #1d2a1f (正文) · ink-500 #5e7263 (出处, 斜体)
//   衬线字体 (Noto Serif SC), 出处右下角 (沿用 v0.15.4 "出处放右下角" 决定)。

// 卡片数据由 FormExtensionAbility 通过 formBindingData 注入到 LocalStorage。
let storage = new LocalStorage();

@Entry(storage)
@Component
struct QuoteCard {
  // @LocalStorageProp 让卡片随 formProvider.updateForm 推送的数据刷新。
  // 默认值是数据桥未通时的静态降级文案 (决策四: 不白屏)。
  @LocalStorageProp('quoteText') quoteText: string = '把光收进来，从裂缝里。';
  @LocalStorageProp('quoteTag') quoteTag: string = '';

  build() {
    Column() {
      // 正文金句 —— 衬线、深墨绿、行距宽松。
      Text(this.quoteText)
        .fontSize(16)
        .fontWeight(FontWeight.Normal)
        .fontColor('#1d2a1f')
        .lineHeight(28)
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 出处 —— 右下角、斜体、淡墨。tag 为空时不占位。
      if (this.quoteTag.length > 0) {
        Text('— ' + this.quoteTag)
          .fontSize(12)
          .fontStyle(FontStyle.Italic)
          .fontColor('#5e7263')
          .margin({ top: 8 })
          .width('100%')
          .textAlign(TextAlign.End)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#e2e6cf')
    // 点击卡片 → 拉起 app 到屏保 (对齐 L18 Android 小组件点击行为)。
    // 里程碑① 先不接路由参数, 仅拉起主 Ability; 深链留里程碑②。
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
      });
    });
  }
}
