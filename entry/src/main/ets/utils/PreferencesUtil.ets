import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN: number = 0x0003;
const TAG: string = 'PrefsUtil';

const PREFS_FILE: string = 'floating_clock_prefs';
const KEY_THEME: string = 'theme_name';
const KEY_MODE: string = 'display_mode';
const KEY_COUNTDOWN_SECONDS: string = 'countdown_seconds';
const KEY_SHOW_DATE: string = 'show_date';
const KEY_WINDOW_X: string = 'window_x';
const KEY_WINDOW_Y: string = 'window_y';

export class PreferencesUtil {
  private static dataPreferences: preferences.DataPreferences | null = null;
  private static context: Context | null = null;

  static init(ctx: Context): void {
    PreferencesUtil.context = ctx;
  }

  private static async getPrefs(): Promise<preferences.DataPreferences | null> {
    if (!PreferencesUtil.context) {
      hilog.error(DOMAIN, TAG, 'Context not initialized');
      return null;
    }
    if (!PreferencesUtil.dataPreferences) {
      try {
        PreferencesUtil.dataPreferences = await preferences.getPreferences(
          PreferencesUtil.context,
          PREFS_FILE
        );
      } catch (err) {
        const e = err as BusinessError;
        hilog.error(DOMAIN, TAG, 'Get prefs failed: %{public}s', JSON.stringify(e));
        return null;
      }
    }
    return PreferencesUtil.dataPreferences;
  }

  private static async put(key: string, value: string | number | boolean): Promise<void> {
    const prefs = await PreferencesUtil.getPrefs();
    if (!prefs) return;
    try {
      prefs.put(key, value);
      await prefs.flush();
    } catch (err) {
      const e = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'Put prefs failed: %{public}s', JSON.stringify(e));
    }
  }

  private static async getString(key: string, defaultValue: string): Promise<string> {
    const prefs = await PreferencesUtil.getPrefs();
    if (!prefs) return defaultValue;
    try {
      const value = await prefs.get(key, defaultValue);
      return String(value);
    } catch (err) {
      return defaultValue;
    }
  }

  private static async getNumber(key: string, defaultValue: number): Promise<number> {
    const prefs = await PreferencesUtil.getPrefs();
    if (!prefs) return defaultValue;
    try {
      const value = await prefs.get(key, defaultValue);
      return Number(value);
    } catch (err) {
      return defaultValue;
    }
  }

  private static async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    const prefs = await PreferencesUtil.getPrefs();
    if (!prefs) return defaultValue;
    try {
      const value = await prefs.get(key, defaultValue);
      return Boolean(value);
    } catch (err) {
      return defaultValue;
    }
  }

  // ------- 公共 API -------

  static async setTheme(theme: string): Promise<void> {
    await PreferencesUtil.put(KEY_THEME, theme);
  }

  static async getTheme(): Promise<string> {
    return PreferencesUtil.getString(KEY_THEME, 'dark');
  }

  static async setMode(mode: string): Promise<void> {
    await PreferencesUtil.put(KEY_MODE, mode);
  }

  static async getMode(): Promise<string> {
    return PreferencesUtil.getString(KEY_MODE, 'clock');
  }

  static async setCountdownSeconds(seconds: number): Promise<void> {
    await PreferencesUtil.put(KEY_COUNTDOWN_SECONDS, seconds);
  }

  static async getCountdownSeconds(): Promise<number> {
    return PreferencesUtil.getNumber(KEY_COUNTDOWN_SECONDS, 300);
  }

  static async setShowDate(show: boolean): Promise<void> {
    await PreferencesUtil.put(KEY_SHOW_DATE, show);
  }

  static async getShowDate(): Promise<boolean> {
    return PreferencesUtil.getBoolean(KEY_SHOW_DATE, true);
  }

  static async setWindowPosition(x: number, y: number): Promise<void> {
    await PreferencesUtil.put(KEY_WINDOW_X, x);
    await PreferencesUtil.put(KEY_WINDOW_Y, y);
  }

  static async getWindowPosition(): Promise<{ x: number; y: number }> {
    const x = await PreferencesUtil.getNumber(KEY_WINDOW_X, 200);
    const y = await PreferencesUtil.getNumber(KEY_WINDOW_Y, 200);
    return { x: x, y: y };
  }
}
