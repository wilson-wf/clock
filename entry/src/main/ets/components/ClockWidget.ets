import { TimeFormatter } from '../utils/TimeFormatter';
import { ThemeStyle } from './Theme';

@Component
export struct ClockWidget {
  @State currentTime: string = '00:00:00';
  @State currentDate: string = '';
  @Prop theme: ThemeStyle;
  @Prop showDate: boolean = true;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.updateTime();
    this.timerId = setInterval(() => {
      this.updateTime();
    }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private updateTime(): void {
    const now = new Date();
    const result = TimeFormatter.formatClock(now);
    this.currentTime = result.time;
    this.currentDate = result.date;
  }

  build() {
    Column({ space: 2 }) {
      Text(this.currentTime)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.textColor)
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(1);

      if (this.showDate) {
        Text(this.currentDate)
          .fontSize(12)
          .fontColor(this.theme.subTextColor)
          .margin({ top: 2 });
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
