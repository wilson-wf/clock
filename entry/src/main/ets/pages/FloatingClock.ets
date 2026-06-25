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
  @State themeName: string = 'harmony_dark';
  @State mode: DisplayMode = 'clock';
  @State showDate: boolean = true;
  @State showMenu: boolean = false;
  @State windowOpacity: number = 75;

  @State countdownIsRunning: boolean = false;
  @State countdownRemaining: number = 300;
  @State countdownTotal: number = 300;

  @State stopwatchIsRunning: boolean = false;
  @State stopwatchElapsed: number = 0;

  @State pomodoroIsRunning: boolean = false;
  @State pomodoroPhase: import('../components/PomodoroWidget').PomodoroPhase = 'work';
  @State pomodoroCompleted: number = 0;
  @State pomodoroRemaining: number = 25 * 60;
  @State pomodoroWorkMin: number = 25;
  @State pomodoroBreakMin: number = 5;
  @State pomodoroLongBreakMin: number = 15;
  @State pomodoroRounds: number = 4;

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
    const savedTheme = await PreferencesUtil.getTheme();
    const existing = ThemeManager.THEMES.find(t => t.name === savedTheme);
    this.themeName = existing ? savedTheme : 'harmony_dark';
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

  private getPrimary(): string {
    return this.getTheme().colors.primary;
  }

  private getSuccess(): string {
    return this.getTheme().colors.success;
  }

  private getDivider(): string {
    return this.getTheme().colors.dividerColor;
  }

  private getTextSecondary(): string {
    return this.getTheme().colors.textSecondary;
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
    if (this.showMenu) {
      this.showMenu = false;
      return;
    }
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
      'clock': '时钟',
      'countdown': '倒计时',
      'stopwatch': '秒表',
      'pomodoro': '番茄钟',
      'worldclock': '世界时钟'
    };
    return labels[this.mode] || this.mode;
  }

  private getModeIcon(): string {
    const icons: Record<DisplayMode, string> = {
      'clock': '🕐',
      'countdown': '⏱️',
      'stopwatch': '⏲️',
      'pomodoro': '🍅',
      'worldclock': '🌍'
    };
    return icons[this.mode];
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
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
      .padding({ left: 18, right: 18, top: 14, bottom: 14 });

      if (this.showMenu) {
        this.buildMenu();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getTheme().bgColor)
    .opacity(this.windowOpacity / 100)
    .borderRadius(20)
    .border({ width: 1, color: this.getTheme().borderColor })
    .shadow({
      radius: 16,
      color: this.getTheme().shadowColor,
      offsetX: 0,
      offsetY: 6
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
      LongPressGesture({ repeat: false, duration: 400 })
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
    Column({ space: 2 }) {
      // 顶部模式标签
      Row({ space: 6 }) {
        Text(this.getModeIcon())
          .fontSize(12);
        Text(this.getModeLabel())
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTheme().colors.textPrimary);
      }
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .backgroundColor(this.getTheme().colors.bgSecondary)
      .borderRadius(100)
      .margin({ bottom: 6 });

      // 菜单项分组 - 显示控制
      this.buildMenuGroup([
        { icon: '🎨', label: '切换主题', onClick: () => this.cycleTheme() },
        { icon: '🔀', label: '切换模式', subLabel: this.getModeLabel(), onClick: () => this.cycleMode() },
        { icon: '📅', label: this.showDate ? '隐藏日期' : '显示日期', onClick: () => this.toggleShowDate() }
      ]);

      // 模式特定操作
      if (this.mode === 'countdown' || this.mode === 'pomodoro' || this.mode === 'stopwatch') {
        this.buildMenuDivider();
        let resetLabel = '重置';
        let resetAction = () => {};
        if (this.mode === 'countdown') {
          resetLabel = '重置倒计时';
          resetAction = () => {
            this.countdownRemaining = this.countdownTotal;
            this.countdownIsRunning = false;
          };
        } else if (this.mode === 'pomodoro') {
          resetLabel = '重置番茄钟';
          resetAction = () => {
            this.pomodoroRemaining = this.pomodoroWorkMin * 60;
            this.pomodoroIsRunning = false;
            this.pomodoroPhase = 'work';
            this.pomodoroCompleted = 0;
          };
        } else {
          resetLabel = '重置秒表';
          resetAction = () => {
            this.stopwatchElapsed = 0;
            this.stopwatchIsRunning = false;
          };
        }
        this.buildMenuGroup([
          { icon: '↺', label: resetLabel, onClick: resetAction }
        ]);
      }

      // 闹钟和状态
      this.buildMenuDivider();
      this.buildMenuGroup([
        {
          icon: '🔔',
          label: this.alarmEnabled
            ? `${String(this.alarmHour).padStart(2, '0')}:${String(this.alarmMinute).padStart(2, '0')}`
            : '闹钟',
          subLabel: this.alarmEnabled ? '已开启' : '主界面设置',
          color: this.alarmEnabled ? this.getSuccess() : undefined,
          onClick: async () => {
            if (this.alarmEnabled) {
              this.alarmEnabled = false;
              await PreferencesUtil.setAlarmEnabled(false);
            } else {
              this.showMenu = false;
            }
          }
        },
        {
          icon: '🔲',
          label: '透明度',
          subLabel: `${this.windowOpacity}%`,
          onClick: () => { this.showMenu = false; }
        }
      ]);

      // 底部操作
      this.buildMenuDivider();
      this.buildMenuGroup([
        { icon: '❌', label: '关闭悬浮窗', color: '#F87171', onClick: () => this.closeFloatingWindow() }
      ]);

      // 收起提示
      Text('▲ 点击空白收起')
        .fontSize(10)
        .fontColor(this.getTheme().colors.textTertiary)
        .margin({ top: 6 })
        .onClick(() => {
          this.showMenu = false;
        });
    }
    .width('100%')
    .height('100%')
    .padding({ top: 14, bottom: 12, left: 12, right: 12 })
    .backgroundColor(this.getTheme().bgColor)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  buildMenuGroup(items: Array<{ icon: string; label: string; subLabel?: string; color?: string; onClick: () => void }>) {
    Column({ space: 0 }) {
      ForEach(items, (item: { icon: string; label: string; subLabel?: string; color?: string; onClick: () => void }, index: number) => {
        Row({ space: 8 }) {
          Text(item.icon)
            .fontSize(14)
            .width(18)
            .textAlign(TextAlign.Center);

          Text(item.label)
            .fontSize(12)
            .fontColor(item.color ?? this.getTheme().colors.textPrimary)
            .layoutWeight(1);

          if (item.subLabel) {
            Text(item.subLabel)
              .fontSize(11)
              .fontColor(item.color ?? this.getTheme().colors.textSecondary);
          }
        }
        .width('100%')
        .height(32)
        .padding({ left: 10, right: 10 })
        .borderRadius(8)
        .onClick(() => item.onClick());
      }, (item: { icon: string; label: string; subLabel?: string; color?: string; onClick: () => void }, index: number) => `${item.label}_${index}`);
    }
    .width('100%')
    .backgroundColor(this.getTheme().colors.bgSecondary)
    .borderRadius(10);
  }

  @Builder
  buildMenuDivider() {
    Divider()
      .strokeWidth(0.5)
      .color(this.getTheme().colors.dividerColor)
      .width('100%')
      .margin({ top: 4, bottom: 4 });
  }
}
