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
const KEY_WINDOW_OPACITY: string = 'window_opacity';
const KEY_POMODORO_WORK: string = 'pomodoro_work_minutes';
const KEY_POMODORO_BREAK: string = 'pomodoro_break_minutes';
const KEY_POMODORO_LONG_BREAK: string = 'pomodoro_long_break_minutes';
const KEY_POMODORO_ROUNDS: string = 'pomodoro_rounds';
const KEY_ALARM_HOUR: string = 'alarm_hour';
const KEY_ALARM_MINUTE: string = 'alarm_minute';
const KEY_ALARM_ENABLED: string = 'alarm_enabled';
const KEY_CUSTOM_BG_COLOR: string = 'custom_bg_color';
const KEY_CUSTOM_TEXT_COLOR: string = 'custom_text_color';
const KEY_USE_CUSTOM_THEME: string = 'use_custom_theme';

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

  // 透明度
  static async setWindowOpacity(opacity: number): Promise<void> {
    await PreferencesUtil.put(KEY_WINDOW_OPACITY, opacity);
  }

  static async getWindowOpacity(): Promise<number> {
    return PreferencesUtil.getNumber(KEY_WINDOW_OPACITY, 75);
  }

  // 番茄钟配置
  static async setPomodoroWorkMinutes(minutes: number): Promise<void> {
    await PreferencesUtil.put(KEY_POMODORO_WORK, minutes);
  }

  static async getPomodoroWorkMinutes(): Promise<number> {
    return PreferencesUtil.getNumber(KEY_POMODORO_WORK, 25);
  }

  static async setPomodoroBreakMinutes(minutes: number): Promise<void> {
    await PreferencesUtil.put(KEY_POMODORO_BREAK, minutes);
  }

  static async getPomodoroBreakMinutes(): Promise<number> {
    return PreferencesUtil.getNumber(KEY_POMODORO_BREAK, 5);
  }

  static async setPomodoroLongBreakMinutes(minutes: number): Promise<void> {
    await PreferencesUtil.put(KEY_POMODORO_LONG_BREAK, minutes);
  }

  static async getPomodoroLongBreakMinutes(): Promise<number> {
    return PreferencesUtil.getNumber(KEY_POMODORO_LONG_BREAK, 15);
  }

  static async setPomodoroRounds(rounds: number): Promise<void> {
    await PreferencesUtil.put(KEY_POMODORO_ROUNDS, rounds);
  }

  static async getPomodoroRounds(): Promise<number> {
    return PreferencesUtil.getNumber(KEY_POMODORO_ROUNDS, 4);
  }

  // 闹钟配置
  static async setAlarmTime(hour: number, minute: number): Promise<void> {
    await PreferencesUtil.put(KEY_ALARM_HOUR, hour);
    await PreferencesUtil.put(KEY_ALARM_MINUTE, minute);
  }

  static async getAlarmTime(): Promise<{ hour: number; minute: number }> {
    const hour = await PreferencesUtil.getNumber(KEY_ALARM_HOUR, 0);
    const minute = await PreferencesUtil.getNumber(KEY_ALARM_MINUTE, 0);
    return { hour: hour, minute: minute };
  }

  static async setAlarmEnabled(enabled: boolean): Promise<void> {
    await PreferencesUtil.put(KEY_ALARM_ENABLED, enabled);
  }

  static async getAlarmEnabled(): Promise<boolean> {
    return PreferencesUtil.getBoolean(KEY_ALARM_ENABLED, false);
  }

  // 自定义主题颜色
  static async setCustomBgColor(color: string): Promise<void> {
    await PreferencesUtil.put(KEY_CUSTOM_BG_COLOR, color);
  }

  static async getCustomBgColor(): Promise<string> {
    return PreferencesUtil.getString(KEY_CUSTOM_BG_COLOR, 'rgba(30, 30, 60, 0.9)');
  }

  static async setCustomTextColor(color: string): Promise<void> {
    await PreferencesUtil.put(KEY_CUSTOM_TEXT_COLOR, color);
  }

  static async getCustomTextColor(): Promise<string> {
    return PreferencesUtil.getString(KEY_CUSTOM_TEXT_COLOR, '#E0E0FF');
  }

  static async setUseCustomTheme(use: boolean): Promise<void> {
    await PreferencesUtil.put(KEY_USE_CUSTOM_THEME, use);
  }

  static async getUseCustomTheme(): Promise<boolean> {
    return PreferencesUtil.getBoolean(KEY_USE_CUSTOM_THEME, false);
  }
}
