import { router } from '@kit.ArkUI';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FloatingWindowManager } from '../utils/FloatingWindowManager';
import { ThemeManager, ThemeStyle } from '../model/Theme';
import { ClockWidget } from '../components/ClockWidget';
import { CountdownWidget } from '../components/CountdownWidget';
import { StopwatchWidget } from '../components/StopwatchWidget';

@Entry
@Component
struct FloatingClock {
  @State themeName: string = 'dark';
  @State mode: string = 'clock';
  @State showDate: boolean = true;
  @State showMenu: boolean = false;

  @State countdownIsRunning: boolean = false;
  @State countdownRemaining: number = 300;
  @State countdownTotal: number = 300;

  @State stopwatchIsRunning: boolean = false;
  @State stopwatchElapsed: number = 0;

  private dragStartX: number = 0;
  private dragStartY: number = 0;
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private movedDuringDrag: boolean = false;

  async aboutToAppear(): Promise<void> {
    this.themeName = await PreferencesUtil.getTheme();
    this.mode = await PreferencesUtil.getMode();
    this.showDate = await PreferencesUtil.getShowDate();
    this.countdownTotal = await PreferencesUtil.getCountdownSeconds();
    this.countdownRemaining = this.countdownTotal;
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
    const modes = ['clock', 'countdown', 'stopwatch'];
    const idx = modes.indexOf(this.mode);
    const next = modes[(idx + 1) % modes.length];
    this.mode = next;
    await PreferencesUtil.setMode(this.mode);
    // 切换时重置状态
    if (this.mode === 'countdown') {
      this.countdownRemaining = this.countdownTotal;
      this.countdownIsRunning = false;
    } else if (this.mode === 'stopwatch') {
      this.stopwatchElapsed = 0;
      this.stopwatchIsRunning = false;
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
    // 简单的视觉反馈：通过主题变化提示用户
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
        } else {
          StopwatchWidget({
            theme: this.getTheme(),
            isRunning: $stopwatchIsRunning,
            elapsedMs: $stopwatchElapsed
          })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 });

      if (this.showMenu) {
        Column({ space: 6 }) {
          Text('设置菜单')
            .fontSize(12)
            .fontColor(this.getTheme().subTextColor)
            .fontWeight(FontWeight.Medium);

          Divider()
            .color(this.getTheme().borderColor)
            .width('80%');

          Text('切换主题')
            .fontSize(13)
            .fontColor(this.getTheme().textColor)
            .padding({ top: 4, bottom: 4 })
            .onClick(() => {
              this.cycleTheme();
            });

          Text('切换模式')
            .fontSize(13)
            .fontColor(this.getTheme().textColor)
            .padding({ top: 4, bottom: 4 })
            .onClick(() => {
              this.cycleMode();
            });

          Text(this.showDate ? '隐藏日期' : '显示日期')
            .fontSize(13)
            .fontColor(this.getTheme().textColor)
            .padding({ top: 4, bottom: 4 })
            .onClick(() => {
              this.toggleShowDate();
            });

          if (this.mode === 'countdown') {
            Text('重置倒计时')
              .fontSize(13)
              .fontColor(this.getTheme().textColor)
              .padding({ top: 4, bottom: 4 })
              .onClick(() => {
                this.countdownRemaining = this.countdownTotal;
                this.countdownIsRunning = false;
              });
          }

          if (this.mode === 'stopwatch') {
            Text('重置秒表')
              .fontSize(13)
              .fontColor(this.getTheme().textColor)
              .padding({ top: 4, bottom: 4 })
              .onClick(() => {
                this.stopwatchElapsed = 0;
                this.stopwatchIsRunning = false;
              });
          }

          Divider()
            .color(this.getTheme().borderColor)
            .width('80%');

          Text('关闭悬浮窗')
            .fontSize(13)
            .fontColor('#FF6B6B')
            .padding({ top: 4, bottom: 4 })
            .onClick(() => {
              this.closeFloatingWindow();
            });

          Text('收起菜单')
            .fontSize(12)
            .fontColor(this.getTheme().subTextColor)
            .padding({ top: 2, bottom: 2 })
            .onClick(() => {
              this.showMenu = false;
            });
        }
        .width('100%')
        .height('100%')
        .padding(12)
        .backgroundColor(this.getTheme().bgColor)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getTheme().bgColor)
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
}
