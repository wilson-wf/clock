/**
 * 番茄钟组件
 * 工作 25 分钟 → 短休息 5 分钟 → 重复 4 轮 → 长休息 15 分钟
 */
import { TimeFormatter } from '../utils/TimeFormatter';
import { ThemeStyle } from '../model/Theme';

export type PomodoroPhase = 'work' | 'shortBreak' | 'longBreak';

@Component
export struct PomodoroWidget {
  @Prop theme: ThemeStyle;
  @Link @Watch('onConfigChanged') workMinutes: number;
  @Link @Watch('onConfigChanged') breakMinutes: number;
  @Link @Watch('onConfigChanged') longBreakMinutes: number;
  @Link @Watch('onConfigChanged') rounds: number;
  @Link @Watch('onStateChanged') isRunning: boolean;
  @Link currentPhase: PomodoroPhase;
  @Link completedRounds: number;
  @Link remainingSeconds: number;

  private timerId: number = -1;

  onConfigChanged(): void {
    if (!this.isRunning) {
      this.resetToPhase();
    }
  }

  onStateChanged(): void {
    if (this.isRunning) {
      this.startTimer();
    } else {
      this.stopTimer();
    }
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private resetToPhase(): void {
    if (this.currentPhase === 'work') {
      this.remainingSeconds = this.workMinutes * 60;
    } else if (this.currentPhase === 'shortBreak') {
      this.remainingSeconds = this.breakMinutes * 60;
    } else {
      this.remainingSeconds = this.longBreakMinutes * 60;
    }
  }

  private startTimer(): void {
    this.stopTimer();
    if (this.remainingSeconds <= 0) {
      this.resetToPhase();
    }
    this.timerId = setInterval(() => {
      if (this.remainingSeconds > 0) {
        this.remainingSeconds -= 1;
        if (this.remainingSeconds === 0) {
          this.isRunning = false;
          this.stopTimer();
          this.onPhaseComplete();
        }
      }
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private onPhaseComplete(): void {
    if (this.currentPhase === 'work') {
      this.completedRounds += 1;
      if (this.completedRounds >= this.rounds) {
        this.currentPhase = 'longBreak';
        this.remainingSeconds = this.longBreakMinutes * 60;
        this.completedRounds = 0;
      } else {
        this.currentPhase = 'shortBreak';
        this.remainingSeconds = this.breakMinutes * 60;
      }
    } else {
      this.currentPhase = 'work';
      this.remainingSeconds = this.workMinutes * 60;
    }
  }

  private getPhaseLabel(): string {
    if (this.currentPhase === 'work') return '专注中';
    if (this.currentPhase === 'shortBreak') return '短休息';
    return '长休息';
  }

  private getProgressRatio(): number {
    let total = 0;
    if (this.currentPhase === 'work') total = this.workMinutes * 60;
    else if (this.currentPhase === 'shortBreak') total = this.breakMinutes * 60;
    else total = this.longBreakMinutes * 60;
    if (total === 0) return 0;
    return (total - this.remainingSeconds) / total;
  }

  private getTimeColor(): string {
    if (this.currentPhase === 'work') return this.theme.textColor;
    return '#81C784';
  }

  build() {
    Column({ space: 4 }) {
      Text(this.getPhaseLabel())
        .fontSize(11)
        .fontColor(this.theme.subTextColor);

      Text(TimeFormatter.formatCountdown(this.remainingSeconds))
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTimeColor())
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(1)
        .margin({ top: 2 });

      Row({ space: 2 }) {
        Text(`${this.completedRounds}/${this.rounds}轮`)
          .fontSize(10)
          .fontColor(this.theme.subTextColor);

        if (this.currentPhase === 'work') {
          Text('🍅')
            .fontSize(10);
        }
      }

      Row({ space: 8 }) {
        if (!this.isRunning) {
          Text('▶ 开始')
            .fontSize(12)
            .fontColor('#81C784')
            .onClick(() => {
              this.isRunning = true;
            });
        } else {
          Text('⏸ 暂停')
            .fontSize(12)
            .fontColor('#FFB74D')
            .onClick(() => {
              this.isRunning = false;
            });
        }

        Text('↺ 重置')
          .fontSize(12)
          .fontColor(this.theme.subTextColor)
          .onClick(() => {
            this.isRunning = false;
            this.completedRounds = 0;
            this.currentPhase = 'work';
            this.resetToPhase();
          });
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
