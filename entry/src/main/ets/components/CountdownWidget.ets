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

  private getTimeColor(): string {
    if (this.remainingSeconds <= 10) {
      return this.theme.colors.danger;
    } else if (this.remainingSeconds <= 30) {
      return this.theme.colors.warning;
    }
    return this.theme.colors.textPrimary;
  }

  private getProgress(): number {
    if (this.totalSeconds === 0) return 0;
    return (this.totalSeconds - this.remainingSeconds) / this.totalSeconds;
  }

  private getProgressColor(): string {
    if (this.remainingSeconds <= 10) {
      return this.theme.colors.danger;
    } else if (this.remainingSeconds <= 30) {
      return this.theme.colors.warning;
    }
    return this.theme.colors.primary;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 2 }) {
        Text(TimeFormatter.formatCountdown(this.remainingSeconds))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTimeColor())
          .fontFamily('HarmonyOS Sans, monospace')
          .letterSpacing(1)
          .lineHeight(34);

        Row({ space: 4 }) {
          Text('⏱')
            .fontSize(10);
          Text('倒计时')
            .fontSize(11)
            .fontColor(this.theme.colors.textSecondary);
        }
      }
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
