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

  private getPhaseIcon(): string {
    if (this.currentPhase === 'work') return '🍅';
    if (this.currentPhase === 'shortBreak') return '☕';
    return '🌙';
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
    if (this.currentPhase === 'work') return this.theme.colors.textPrimary;
    return this.theme.colors.success;
  }

  private getPhaseColor(): string {
    if (this.currentPhase === 'work') return '#F87171';
    if (this.currentPhase === 'shortBreak') return this.theme.colors.success;
    return '#60A5FA';
  }

  build() {
    Column({ space: 6 }) {
      // 阶段标签
      Row({ space: 4 }) {
        Text(this.getPhaseIcon())
          .fontSize(11);
        Text(this.getPhaseLabel())
          .fontSize(11)
          .fontColor(this.theme.colors.textSecondary);
      }
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .backgroundColor(this.theme.colors.bgSecondary)
      .borderRadius(100);

      // 时间显示
      Text(TimeFormatter.formatCountdown(this.remainingSeconds))
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTimeColor())
        .fontFamily('HarmonyOS Sans, monospace')
        .letterSpacing(1)
        .lineHeight(32);

      // 进度条
      Stack({ alignContent: Alignment.Start }) {
        // 背景轨道
        Rect()
          .width('100%')
          .height(4)
          .fill(this.theme.colors.bgSecondary)
          .borderRadius(2);

        // 进度条
        Rect()
          .width(`${this.getProgressRatio() * 100}%`)
          .height(4)
          .fill(this.getPhaseColor())
          .borderRadius(2);
      }
      .width('100%')
      .height(4);

      // 轮数 + 操作按钮
      Row({ space: 8 }) {
        // 轮数指示
        Row({ space: 2 }) {
          ForEach(Array.from({ length: this.rounds }, (_, i) => i), (index: number) => {
            Circle()
              .width(5)
              .height(5)
              .fill(index < this.completedRounds ? this.getPhaseColor() : this.theme.colors.bgSecondary);
          }, (index: number) => index.toString());
        }
        .layoutWeight(1);

        // 操作按钮
        if (!this.isRunning) {
          Row({ space: 4 }) {
            Text('▶')
              .fontSize(12)
              .fontColor(this.theme.colors.success);
            Text('开始')
              .fontSize(11)
              .fontColor(this.theme.colors.textPrimary);
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.theme.colors.bgSecondary)
          .borderRadius(8)
          .onClick(() => {
            this.isRunning = true;
          });
        } else {
          Row({ space: 4 }) {
            Text('⏸')
              .fontSize(12)
              .fontColor(this.theme.colors.warning);
            Text('暂停')
              .fontSize(11)
              .fontColor(this.theme.colors.textPrimary);
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.theme.colors.bgSecondary)
          .borderRadius(8)
          .onClick(() => {
            this.isRunning = false;
          });
        }
      }
      .width('100%');
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
