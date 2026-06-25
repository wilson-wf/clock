import { TimeFormatter } from '../utils/TimeFormatter';
import { ThemeStyle } from '../model/Theme';

@Component
export struct StopwatchWidget {
  @Prop theme: ThemeStyle;
  @Link @Watch('onRunningChanged') isRunning: boolean;
  @Link elapsedMs: number;
  private timerId: number = -1;
  private lastTick: number = 0;

  onRunningChanged(): void {
    if (this.isRunning) {
      this.startTimer();
    } else {
      this.stopTimer();
    }
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private startTimer(): void {
    this.stopTimer();
    this.lastTick = Date.now();
    this.timerId = setInterval(() => {
      const now = Date.now();
      const delta = now - this.lastTick;
      this.lastTick = now;
      this.elapsedMs += delta;
    }, 50);
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  build() {
    Column({ space: 2 }) {
      Text(TimeFormatter.formatStopwatch(this.elapsedMs))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.colors.textPrimary)
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(1)
        .lineHeight(34);

      Row({ space: 4 }) {
        Text('⏲')
          .fontSize(10);
        Text('秒表')
          .fontSize(11)
          .fontColor(this.theme.colors.textSecondary);
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
