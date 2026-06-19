import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FloatingWindowManager } from '../utils/FloatingWindowManager';
import { ThemeManager, ThemeStyle } from '../model/Theme';
import { TimeFormatter } from '../utils/TimeFormatter';

@Entry
@Component
struct Index {
  @State currentTheme: string = 'dark';
  @State currentMode: string = 'clock';
  @State showDate: boolean = true;
  @State countdownMinutes: number = 5;
  @State countdownTotal: number = 300;
  @State isFloatingShown: boolean = false;
  @State previewTime: string = '00:00:00';
  @State previewDate: string = '';
  private timerId: number = -1;

  aboutToAppear(): void {
    this.loadPreferences();
    this.updatePreviewTime();
    this.timerId = setInterval(() => {
      this.updatePreviewTime();
    }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private async loadPreferences(): Promise<void> {
    this.currentTheme = await PreferencesUtil.getTheme();
    this.currentMode = await PreferencesUtil.getMode();
    this.showDate = await PreferencesUtil.getShowDate();
    this.countdownTotal = await PreferencesUtil.getCountdownSeconds();
    this.countdownMinutes = Math.floor(this.countdownTotal / 60);
    this.isFloatingShown = FloatingWindowManager.getInstance().isWindowShown();
  }

  private updatePreviewTime(): void {
    const now = new Date();
    const result = TimeFormatter.formatClock(now);
    this.previewTime = result.time;
    this.previewDate = result.date;
  }

  private getTheme(): ThemeStyle {
    return ThemeManager.getTheme(this.currentTheme);
  }

  private async selectTheme(name: string): Promise<void> {
    this.currentTheme = name;
    await PreferencesUtil.setTheme(name);
  }

  private async selectMode(mode: string): Promise<void> {
    this.currentMode = mode;
    await PreferencesUtil.setMode(mode);
  }

  private async toggleShowDate(): Promise<void> {
    this.showDate = !this.showDate;
    await PreferencesUtil.setShowDate(this.showDate);
  }

  private async onCountdownMinutesChanged(value: number): Promise<void> {
    this.countdownMinutes = value;
    const total = value * 60;
    this.countdownTotal = total;
    await PreferencesUtil.setCountdownSeconds(total);
  }

  private async showFloatingWindow(): Promise<void> {
    const pos = await PreferencesUtil.getWindowPosition();
    const ok = await FloatingWindowManager.getInstance().createFloatingWindow(
      240,
      120,
      pos.x,
      pos.y
    );
    this.isFloatingShown = ok;
  }

  private async hideFloatingWindow(): Promise<void> {
    await FloatingWindowManager.getInstance().hideFloatingWindow();
    this.isFloatingShown = false;
  }

  build() {
    Column() {
      Text('悬浮时钟')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: 40, bottom: 24 });

      Column() {
        Text(this.previewTime)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTheme().textColor)
          .letterSpacing(1);
        if (this.showDate) {
          Text(this.previewDate)
            .fontSize(14)
            .fontColor(this.getTheme().subTextColor)
            .margin({ top: 4 });
        }
      }
      .width('90%')
      .height(120)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(this.getTheme().bgColor)
      .borderRadius(16)
      .border({ width: 1, color: this.getTheme().borderColor })
      .shadow({
        radius: 16,
        color: this.getTheme().shadowColor,
        offsetX: 2,
        offsetY: 6
      })
      .margin({ bottom: 28 });

      Text('主题选择')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('90%')
        .margin({ bottom: 10 });

      Grid() {
        ForEach(ThemeManager.THEMES, (theme: ThemeStyle) => {
          GridItem() {
            Column({ space: 4 }) {
              Text('12:34')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(theme.textColor);
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .backgroundColor(theme.bgColor)
            .borderRadius(12)
            .border({
              width: this.currentTheme === theme.name ? 3 : 1,
              color: this.currentTheme === theme.name ? '#4FC3F7' : theme.borderColor
            });
            Text(theme.label)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ top: 4 });
          }
          .height(80)
          .onClick(() => this.selectTheme(theme.name));
        }, (theme: ThemeStyle) => theme.name);
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('90%')
      .height(190)
      .margin({ bottom: 28 });

      Text('显示模式')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('90%')
        .margin({ bottom: 10 });

      Row({ space: 10 }) {
        Button('实时时钟')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentMode === 'clock' ? '#4FC3F7' : '#3A3A3A')
          .height(44)
          .layoutWeight(1)
          .onClick(() => this.selectMode('clock'));

        Button('倒计时')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentMode === 'countdown' ? '#4FC3F7' : '#3A3A3A')
          .height(44)
          .layoutWeight(1)
          .onClick(() => this.selectMode('countdown'));

        Button('秒表')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentMode === 'stopwatch' ? '#4FC3F7' : '#3A3A3A')
          .height(44)
          .layoutWeight(1)
          .onClick(() => this.selectMode('stopwatch'));
      }
      .width('90%')
      .margin({ bottom: 24 });

      if (this.currentMode === 'countdown') {
        Column() {
          Row() {
            Text('倒计时分钟数')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .layoutWeight(1);
            Text(`${this.countdownMinutes} 分钟`)
              .fontSize(14)
              .fontColor('#4FC3F7')
              .fontWeight(FontWeight.Medium);
          }
          .width('100%')
          .margin({ bottom: 8 });

          Slider({
            value: this.countdownMinutes,
            min: 1,
            max: 60,
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor('#4FC3F7')
            .selectedColor('#4FC3F7')
            .trackColor('#555555')
            .onChange((value: number) => this.onCountdownMinutesChanged(Math.floor(value)));
        }
        .width('90%')
        .margin({ bottom: 24 });
      }

      Row() {
        Text('显示日期')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .layoutWeight(1);
        Toggle({ type: ToggleType.Switch, isOn: this.showDate })
          .selectedColor('#4FC3F7')
          .switchPointColor('#FFFFFF')
          .onChange((isOn: boolean) => this.toggleShowDate());
      }
      .width('90%')
      .margin({ bottom: 36 });

      if (this.isFloatingShown) {
        Button('隐藏悬浮窗')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B6B')
          .width('90%')
          .height(52)
          .borderRadius(26)
          .onClick(() => this.hideFloatingWindow());
      } else {
        Button('显示悬浮窗')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#4FC3F7')
          .width('90%')
          .height(52)
          .borderRadius(26)
          .onClick(() => this.showFloatingWindow());
      }

      Column({ space: 4 }) {
        Text('使用提示：')
          .fontSize(12)
          .fontColor('#888888')
          .width('90%')
          .margin({ top: 24 });
        Text('• 长按悬浮窗可打开设置菜单')
          .fontSize(12)
          .fontColor('#888888')
          .width('90%');
        Text('• 拖动可自由改变位置')
          .fontSize(12)
          .fontColor('#888888')
          .width('90%');
        Text('• 单击可开始/暂停倒计时或秒表')
          .fontSize(12)
          .fontColor('#888888')
          .width('90%');
      }
      .margin({ bottom: 40 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A1A')
    .alignItems(HorizontalAlign.Center);
  }
}
