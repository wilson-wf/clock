export class TimeFormatter {
  static pad(num: number): string {
    return num < 10 ? '0' + num : String(num);
  }

  static formatClock(date: Date): { time: string; date: string } {
    const h = TimeFormatter.pad(date.getHours());
    const m = TimeFormatter.pad(date.getMinutes());
    const s = TimeFormatter.pad(date.getSeconds());
    const time = `${h}:${m}:${s}`;

    const year = date.getFullYear();
    const month = TimeFormatter.pad(date.getMonth() + 1);
    const day = TimeFormatter.pad(date.getDate());
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekday = weekdays[date.getDay()];
    const dateStr = `${year}/${month}/${day} ${weekday}`;

    return { time: time, date: dateStr };
  }

  static formatCountdown(totalSeconds: number): string {
    if (totalSeconds < 0) totalSeconds = 0;
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${TimeFormatter.pad(hours)}:${TimeFormatter.pad(minutes)}:${TimeFormatter.pad(seconds)}`;
    }
    return `${TimeFormatter.pad(minutes)}:${TimeFormatter.pad(seconds)}`;
  }

  static formatStopwatch(totalMilliseconds: number): string {
    const totalSeconds = Math.floor(totalMilliseconds / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    const ms = Math.floor((totalMilliseconds % 1000) / 10);

    if (hours > 0) {
      return `${TimeFormatter.pad(hours)}:${TimeFormatter.pad(minutes)}:${TimeFormatter.pad(seconds)}.${TimeFormatter.pad(ms)}`;
    }
    return `${TimeFormatter.pad(minutes)}:${TimeFormatter.pad(seconds)}.${TimeFormatter.pad(ms)}`;
  }
}
