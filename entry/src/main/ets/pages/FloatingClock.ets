import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FloatingWindowManager } from '../utils/FloatingWindowManager';
import { ThemeManager, ThemeStyle } from '../model/Theme';
import { ClockWidget } from '../components/ClockWidget';
import { CountdownWidget } from '../components/CountdownWidget';
import { StopwatchWidget } from '../components/StopwatchWidget';
import { PomodoroWidget } from '../components/PomodoroWidget';
import { WorldClockWidget } from '../components/WorldClockWidget';

export type DisplayMode = 'clock' | 'countdown' | 'stopwatch' | 'pomodoro' | 'worldclock';

@Entry
@Component
struct FloatingClock {
  @State themeName: string = 'dark';
  @State mode: DisplayMode = 'clock';
  @State showDate: boolean = true;
  @State showMenu: boolean = false;
  @State windowOpacity: number = 75;

  // 倒计时
  @State countdownIsRunning: boolean = false;
  @State countdownRemaining: number = 300;
  @State countdownTotal: number = 300;

  // 秒表
  @State stopwatchIsRunning: boolean = false;
  @State stopwatchElapsed: number = 0;

  // 番茄钟
  @State pomodoroIsRunning: boolean = false;
  @State pomodoroPhase: import('../components/PomodoroWidget').PomodoroPhase = 'work';
  @State pomodoroCompleted: number = 0;
  @State pomodoroRemaining: number = 25 * 60;
  @State pomodoroWorkMin: number = 25;
  @State pomodoroBreakMin: number = 5;
  @State pomodoroLongBreakMin: number = 15;
  @State pomodoroRounds: number = 4;

  // 闹钟
  @State alarmHour: number = 0;
  @State alarmMinute: number = 0;
  @State alarmEnabled: boolean = false;
  private alarmCheckTimer: number = -1;

  private dragStartX: number = 0;
  private dragStartY: number = 0;
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private movedDuringDrag: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.themeName = await PreferencesUtil.getTheme();
    this.mode = (await PreferencesUtil.getMode()) as DisplayMode;
    this.showDate = await PreferencesUtil.getShowDate();
    this.windowOpacity = await PreferencesUtil.getWindowOpacity();
    this.countdownTotal = await PreferencesUtil.getCountdownSeconds();
    this.countdownRemaining = this.countdownTotal;
    this.pomodoroWorkMin = await PreferencesUtil.getPomodoroWorkMinutes();
    this.pomodoroBreakMin = await PreferencesUtil.getPomodoroBreakMinutes();
    this.pomodoroLongBreakMin = await PreferencesUtil.getPomodoroLongBreakMinutes();
    this.pomodoroRounds = await PreferencesUtil.getPomodoroRounds();
    this.pomodoroRemaining = this.pomodoroWorkMin * 60;
    const alarmTime = await PreferencesUtil.getAlarmTime();
    this.alarmHour = alarmTime.hour;
    this.alarmMinute = alarmTime.minute;
    this.alarmEnabled = await PreferencesUtil.getAlarmEnabled();
    this.startAlarmChecker();
  }

  aboutToDisappear(): void {
    if (this.alarmCheckTimer !== -1) {
      clearInterval(this.alarmCheckTimer);
      this.alarmCheckTimer = -1;
    }
  }

  private startAlarmChecker(): void {
    this.alarmCheckTimer = setInterval(() => {
      if (!this.alarmEnabled) return;
      const now = new Date();
      if (now.getHours() === this.alarmHour && now.getMinutes() === this.alarmMinute && now.getSeconds() === 0) {
        this.triggerAlarm();
      }
    }, 1000);
  }

  private triggerAlarm(): void {
    this.alarmEnabled = false;
    PreferencesUtil.setAlarmEnabled(false);
  }

  private getTheme(): ThemeStyle {
    return ThemeManager.getTheme(this.themeName);
  }

  private async cycleTheme(): Promise<void> {
    const themes = ThemeManager.THEMES;
    const idx = themes.findIndex((t) => t.name === this.themeName);
    const next = themes[(idx + 1) % themes.length];
    this.themeName = next.name;
    await PreferencesUtil.setTheme(this.themeName);
  }

  private async cycleMode(): Promise<void> {
    const modes: DisplayMode[] = ['clock', 'countdown', 'stopwatch', 'pomodoro', 'worldclock'];
    const idx = modes.indexOf(this.mode);
    this.mode = modes[(idx + 1) % modes.length];
    await PreferencesUtil.setMode(this.mode);
    this.resetCurrentMode();
  }

  private resetCurrentMode(): void {
    if (this.mode === 'countdown') {
      this.countdownRemaining = this.countdownTotal;
      this.countdownIsRunning = false;
    } else if (this.mode === 'stopwatch') {
      this.stopwatchElapsed = 0;
      this.stopwatchIsRunning = false;
    } else if (this.mode === 'pomodoro') {
      this.pomodoroRemaining = this.pomodoroWorkMin * 60;
      this.pomodoroIsRunning = false;
      this.pomodoroPhase = 'work';
      this.pomodoroCompleted = 0;
    }
  }

  private handleSingleClick(): void {
    if (this.mode === 'countdown') {
      if (this.countdownRemaining <= 0) {
        this.countdownRemaining = this.countdownTotal;
      }
      this.countdownIsRunning = !this.countdownIsRunning;
    } else if (this.mode === 'stopwatch') {
      this.stopwatchIsRunning = !this.stopwatchIsRunning;
    } else if (this.mode === 'pomodoro') {
      this.pomodoroIsRunning = !this.pomodoroIsRunning;
    } else {
      this.showMenu = !this.showMenu;
    }
  }

  private handleLongPress(): void {
    this.showMenu = !this.showMenu;
  }

  private async toggleShowDate(): Promise<void> {
    this.showDate = !this.showDate;
    await PreferencesUtil.setShowDate(this.showDate);
  }

  private handleCountdownFinished(): void {
    if (this.mode !== 'countdown') return;
    this.showMenu = true;
  }

  private onPanStart(event: GestureEvent): void {
    const pos = FloatingWindowManager.getInstance().getPosition();
    this.windowStartX = pos.x;
    this.windowStartY = pos.y;
    this.dragStartX = event.offsetX;
    this.dragStartY = event.offsetY;
    this.movedDuringDrag = false;
  }

  private onPanUpdate(event: GestureEvent): void {
    const dx = event.offsetX - this.dragStartX;
    const dy = event.offsetY - this.dragStartY;
    const threshold = 5;
    if (Math.abs(dx) > threshold || Math.abs(dy) > threshold) {
      this.movedDuringDrag = true;
      const newX = Math.max(0, this.windowStartX + dx);
      const newY = Math.max(0, this.windowStartY + dy);
      FloatingWindowManager.getInstance().moveWindowTo(Math.floor(newX), Math.floor(newY));
    }
  }

  private async onPanEnd(): Promise<void> {
    const pos = FloatingWindowManager.getInstance().getPosition();
    await PreferencesUtil.setWindowPosition(pos.x, pos.y);
  }

  private closeFloatingWindow(): void {
    FloatingWindowManager.getInstance().hideFloatingWindow();
  }

  private getModeLabel(): string {
    const labels: Record<DisplayMode, string> = {
      'clock': '实时时钟',
      'countdown': '倒计时',
      'stopwatch': '秒表',
      'pomodoro': '番茄钟',
      'worldclock': '世界时钟'
    };
    return labels[this.mode] || this.mode;
  }

  build() {
    Stack() {
      Column() {
        if (this.mode === 'clock') {
          ClockWidget({
            theme: this.getTheme(),
            showDate: this.showDate
          })
        } else if (this.mode === 'countdown') {
          CountdownWidget({
            theme: this.getTheme(),
            totalSeconds: this.countdownTotal,
            isRunning: $countdownIsRunning,
            remainingSeconds: $countdownRemaining,
            onFinished: () => this.handleCountdownFinished()
          })
        } else if (this.mode === 'stopwatch') {
          StopwatchWidget({
            theme: this.getTheme(),
            isRunning: $stopwatchIsRunning,
            elapsedMs: $stopwatchElapsed
          })
        } else if (this.mode === 'pomodoro') {
          PomodoroWidget({
            theme: this.getTheme(),
            workMinutes: $pomodoroWorkMin,
            breakMinutes: $pomodoroBreakMin,
            longBreakMinutes: $pomodoroLongBreakMin,
            rounds: $pomodoroRounds,
            isRunning: $pomodoroIsRunning,
            currentPhase: $pomodoroPhase,
            completedRounds: $pomodoroCompleted,
            remainingSeconds: $pomodoroRemaining
          })
        } else if (this.mode === 'worldclock') {
          WorldClockWidget({
            theme: this.getTheme()
          })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 });

      if (this.showMenu) {
        this.buildMenu();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getTheme().bgColor)
    .opacity(this.windowOpacity / 100)
    .borderRadius(16)
    .border({ width: 1, color: this.getTheme().borderColor })
    .shadow({
      radius: 12,
      color: this.getTheme().shadowColor,
      offsetX: 2,
      offsetY: 4
    })
    .gesture(
      TapGesture({ count: 1 })
        .onAction(() => {
          if (!this.movedDuringDrag) {
            this.handleSingleClick();
          }
        })
    )
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          this.handleLongPress();
        })
    )
    .gesture(
      PanGesture({ distance: 5 })
        .onActionStart((event: GestureEvent) => this.onPanStart(event))
        .onActionUpdate((event: GestureEvent) => this.onPanUpdate(event))
        .onActionEnd(() => this.onPanEnd())
    );
  }

  @Builder
  buildMenu() {
    Column({ space: 5 }) {
      Text(`【${this.getModeLabel()}】设置`)
        .fontSize(12)
        .fontColor(this.getTheme().subTextColor)
        .fontWeight(FontWeight.Medium);

      Divider().color(this.getTheme().borderColor).width('80%');

      Text('🔄 切换主题')
        .fontSize(13)
        .fontColor(this.getTheme().textColor)
        .padding({ top: 3, bottom: 3 })
        .onClick(() => this.cycleTheme());

      Text(`📋 切换模式（${this.getModeLabel()}）`)
        .fontSize(13)
        .fontColor(this.getTheme().textColor)
        .padding({ top: 3, bottom: 3 })
        .onClick(() => this.cycleMode());

      Text(this.showDate ? '📅 隐藏日期' : '📅 显示日期')
        .fontSize(13)
        .fontColor(this.getTheme().textColor)
        .padding({ top: 3, bottom: 3 })
        .onClick(() => this.toggleShowDate());

      if (this.mode === 'countdown') {
        Text('🔄 重置倒计时')
          .fontSize(13)
          .fontColor(this.getTheme().textColor)
          .padding({ top: 3, bottom: 3 })
          .onClick(() => {
            this.countdownRemaining = this.countdownTotal;
            this.countdownIsRunning = false;
          });
      }

      if (this.mode === 'pomodoro') {
        Text('🔄 重置番茄钟')
          .fontSize(13)
          .fontColor(this.getTheme().textColor)
          .padding({ top: 3, bottom: 3 })
          .onClick(() => {
            this.pomodoroRemaining = this.pomodoroWorkMin * 60;
            this.pomodoroIsRunning = false;
            this.pomodoroPhase = 'work';
            this.pomodoroCompleted = 0;
          });
      }

      if (this.mode === 'stopwatch') {
        Text('🔄 重置秒表')
          .fontSize(13)
          .fontColor(this.getTheme().textColor)
          .padding({ top: 3, bottom: 3 })
          .onClick(() => {
            this.stopwatchElapsed = 0;
            this.stopwatchIsRunning = false;
          });
      }

      Divider().color(this.getTheme().borderColor).width('80%');

      if (this.alarmEnabled) {
        Text(`🔔 闹钟 ${String(this.alarmHour).padStart(2, '0')}:${String(this.alarmMinute).padStart(2, '0')} 已开启`)
          .fontSize(12)
          .fontColor('#81C784')
          .padding({ top: 3, bottom: 3 })
          .onClick(async () => {
            this.alarmEnabled = false;
            await PreferencesUtil.setAlarmEnabled(false);
          });
      } else {
        Text('🔔 设置闹钟（主界面）')
          .fontSize(12)
          .fontColor(this.getTheme().subTextColor)
          .padding({ top: 3, bottom: 3 })
          .onClick(() => this.showMenu = false);
      }

      Text('⏱ 透明度调节（主界面）')
        .fontSize(12)
        .fontColor(this.getTheme().subTextColor)
        .padding({ top: 3, bottom: 3 })
        .onClick(() => this.showMenu = false);

      Divider().color(this.getTheme().borderColor).width('80%');

      Text('❌ 关闭悬浮窗')
        .fontSize(13)
        .fontColor('#FF6B6B')
        .padding({ top: 3, bottom: 3 })
        .onClick(() => this.closeFloatingWindow());

      Text('▲ 收起菜单')
        .fontSize(11)
        .fontColor(this.getTheme().subTextColor)
        .padding({ top: 2, bottom: 2 })
        .onClick(() => {
          this.showMenu = false;
        });
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor(this.getTheme().bgColor)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }
}
