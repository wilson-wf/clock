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
    Column({ space: 4 }) {
      Text(TimeFormatter.formatStopwatch(this.elapsedMs))
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.theme.textColor)
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(1)
        .margin({ top: 4 });

      Text('秒表')
        .fontSize(11)
        .fontColor(this.theme.subTextColor);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
