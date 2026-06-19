import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';

const DOMAIN: number = 0x0002;
const TAG: string = 'FloatingWindowMgr';

export const FLOATING_WINDOW_NAME: string = 'floating_clock_widget';

export class FloatingWindowManager {
  private static instance: FloatingWindowManager | null = null;
  private context: Context | null = null;
  private floatingWindow: window.Window | null = null;
  private currentX: number = 200;
  private currentY: number = 200;
  private isShown: boolean = false;

  static getInstance(): FloatingWindowManager {
    if (!FloatingWindowManager.instance) {
      FloatingWindowManager.instance = new FloatingWindowManager();
    }
    return FloatingWindowManager.instance;
  }

  setContext(context: Context): void {
    this.context = context;
  }

  getWindow(): window.Window | null {
    return this.floatingWindow;
  }

  isWindowShown(): boolean {
    return this.isShown;
  }

  /**
   * 创建悬浮窗：置顶 + 可拖动 + 透明背景
   */
  async createFloatingWindow(
    width: number = 240,
    height: number = 120,
    startX: number = 200,
    startY: number = 200
  ): Promise<boolean> {
    if (!this.context) {
      hilog.error(DOMAIN, TAG, 'Context is null, cannot create floating window');
      return false;
    }

    if (this.floatingWindow) {
      hilog.info(DOMAIN, TAG, 'Floating window already exists, showing it');
      this.showFloatingWindow();
      return true;
    }

    try {
      this.currentX = startX;
      this.currentY = startY;

      this.floatingWindow = await window.createWindow(
        this.context,
        FLOATING_WINDOW_NAME,
        window.WindowType.TYPE_FLOAT
      );

      if (!this.floatingWindow) {
        hilog.error(DOMAIN, TAG, 'Failed to create floating window');
        return false;
      }

      await this.floatingWindow.setWindowLayout(width, height);
      await this.floatingWindow.moveWindowTo(startX, startY);
      await this.floatingWindow.setWindowBackgroundColor('#00000000');
      await this.floatingWindow.setUIContent('pages/FloatingClock');
      await this.floatingWindow.setWindowFocusable(false);
      await this.floatingWindow.setWindowTouchable(true);
      await this.floatingWindow.showWindow();

      this.isShown = true;
      hilog.info(DOMAIN, TAG, 'Floating window created and shown at (%{public}d, %{public}d)', startX, startY);
      return true;
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'Create floating window failed: %{public}s', JSON.stringify(e));
      return false;
    }
  }

  async moveWindowTo(x: number, y: number): Promise<void> {
    if (!this.floatingWindow) return;
    this.currentX = x;
    this.currentY = y;
    try {
      await this.floatingWindow.moveWindowTo(x, y);
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'Move window failed: %{public}s', JSON.stringify(e));
    }
  }

  async setWindowLayout(width: number, height: number): Promise<void> {
    if (!this.floatingWindow) return;
    try {
      await this.floatingWindow.setWindowLayout(width, height);
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'Set window layout failed: %{public}s', JSON.stringify(e));
    }
  }

  async hideFloatingWindow(): Promise<void> {
    if (!this.floatingWindow) return;
    try {
      await this.floatingWindow.hideWindow();
      this.isShown = false;
      hilog.info(DOMAIN, TAG, 'Floating window hidden');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'Hide window failed: %{public}s', JSON.stringify(e));
    }
  }

  async showFloatingWindow(): Promise<void> {
    if (!this.floatingWindow) return;
    try {
      await this.floatingWindow.showWindow();
      this.isShown = true;
      hilog.info(DOMAIN, TAG, 'Floating window shown');
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'Show window failed: %{public}s', JSON.stringify(e));
    }
  }

  destroyFloatingWindow(): void {
    if (this.floatingWindow) {
      this.floatingWindow.destroyWindow((err: BusinessError) => {
        if (err.code) {
          hilog.error(DOMAIN, TAG, 'Destroy window failed: %{public}d', err.code);
        } else {
          hilog.info(DOMAIN, TAG, 'Floating window destroyed');
        }
      });
      this.floatingWindow = null;
      this.isShown = false;
    }
  }

  getPosition(): { x: number; y: number } {
    return { x: this.currentX, y: this.currentY };
  }
}
