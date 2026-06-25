import { TimeFormatter } from '../utils/TimeFormatter';
import { ThemeStyle } from '../model/Theme';

@Component
export struct ClockWidget {
  @State currentTime: string = '00:00:00';
  @State currentDate: string = '';
  @State currentWeekday: string = '';
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
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    this.currentWeekday = weekdays[now.getDay()];
  }

  build() {
    Column({ space: 4 }) {
      Text(this.currentTime)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.colors.textPrimary)
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(2)
        .lineHeight(36);

      if (this.showDate) {
        Row({ space: 6 }) {
          Text(this.currentDate)
            .fontSize(12)
            .fontColor(this.theme.colors.textSecondary);

          Circle()
            .width(3)
            .height(3)
            .fill(this.theme.colors.textTertiary);

          Text(this.currentWeekday)
            .fontSize(12)
            .fontColor(this.theme.colors.textSecondary);
        }
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
