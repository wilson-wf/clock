import { TimeFormatter } from '../utils/TimeFormatter';
import { ThemeStyle } from '../model/Theme';

@Component
export struct CountdownWidget {
  @Prop theme: ThemeStyle;
  @Prop totalSeconds: number = 300;
  @Link @Watch('onRunningChanged') isRunning: boolean;
  @Link remainingSeconds: number;
  @Prop onFinished: () => void = () => {};
  private timerId: number = -1;

  onRunningChanged(): void {
    if (this.isRunning) {
      this.startTimer();
    } else {
      this.stopTimer();
    }
  }

  aboutToAppear(): void {
    if (this.remainingSeconds <= 0) {
      this.remainingSeconds = this.totalSeconds;
    }
    if (this.isRunning) {
      this.startTimer();
    }
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private startTimer(): void {
    this.stopTimer();
    this.timerId = setInterval(() => {
      if (this.remainingSeconds > 0) {
        this.remainingSeconds -= 1;
        if (this.remainingSeconds === 0) {
          this.isRunning = false;
          this.onFinished();
        }
      } else {
        this.isRunning = false;
        this.stopTimer();
      }
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private getColor(): string {
    if (this.remainingSeconds <= 10) {
      return '#FF5252';
    } else if (this.remainingSeconds <= 30) {
      return '#FFB74D';
    }
    return this.theme.textColor;
  }

  build() {
    Column({ space: 4 }) {
      Text(TimeFormatter.formatCountdown(this.remainingSeconds))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getColor())
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(1)
        .margin({ top: 4 });

      Text('倒计时')
        .fontSize(11)
        .fontColor(this.theme.subTextColor);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
