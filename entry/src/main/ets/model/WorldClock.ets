/**
 * 世界时钟数据模型
 */
export interface CityTime {
  id: string;
  name: string;          // 显示名称
  zone: string;          // IANA 时区 ID (e.g. 'America/New_York')
  offsetHours: number;   // 与 UTC 的整数小时偏移
  offsetMinutes: number;  // 额外分钟偏移（如 +5:30）
  flag: string;          // 表情旗帜
}

export class WorldClockData {
  static readonly CITIES: CityTime[] = [
    { id: 'beijing', name: '北京', zone: 'Asia/Shanghai', offsetHours: 8, offsetMinutes: 0, flag: '🇨🇳' },
    { id: 'shanghai', name: '上海', zone: 'Asia/Shanghai', offsetHours: 8, offsetMinutes: 0, flag: '🇨🇳' },
    { id: 'tokyo', name: '东京', zone: 'Asia/Tokyo', offsetHours: 9, offsetMinutes: 0, flag: '🇯🇵' },
    { id: 'seoul', name: '首尔', zone: 'Asia/Seoul', offsetHours: 9, offsetMinutes: 0, flag: '🇰🇷' },
    { id: 'hongkong', name: '香港', zone: 'Asia/Hong_Kong', offsetHours: 8, offsetMinutes: 0, flag: '🇭🇰' },
    { id: 'singapore', name: '新加坡', zone: 'Asia/Singapore', offsetHours: 8, offsetMinutes: 0, flag: '🇸🇬' },
    { id: 'mumbai', name: '孟买', zone: 'Asia/Kolkata', offsetHours: 5, offsetMinutes: 30, flag: '🇮🇳' },
    { id: 'dubai', name: '迪拜', zone: 'Asia/Dubai', offsetHours: 4, offsetMinutes: 0, flag: '🇦🇪' },
    { id: 'moscow', name: '莫斯科', zone: 'Europe/Moscow', offsetHours: 3, offsetMinutes: 0, flag: '🇷🇺' },
    { id: 'paris', name: '巴黎', zone: 'Europe/Paris', offsetHours: 2, offsetMinutes: 0, flag: '🇫🇷' },
    { id: 'london', name: '伦敦', zone: 'Europe/London', offsetHours: 1, offsetMinutes: 0, flag: '🇬🇧' },
    { id: 'berlin', name: '柏林', zone: 'Europe/Berlin', offsetHours: 2, offsetMinutes: 0, flag: '🇩🇪' },
    { id: 'cairo', name: '开罗', zone: 'Africa/Cairo', offsetHours: 2, offsetMinutes: 0, flag: '🇪🇬' },
    { id: 'newyork', name: '纽约', zone: 'America/New_York', offsetHours: -4, offsetMinutes: 0, flag: '🇺🇸' },
    { id: 'losangeles', name: '洛杉矶', zone: 'America/Los_Angeles', offsetHours: -7, offsetMinutes: 0, flag: '🇺🇸' },
    { id: 'chicago', name: '芝加哥', zone: 'America/Chicago', offsetHours: -5, offsetMinutes: 0, flag: '🇺🇸' },
    { id: 'toronto', name: '多伦多', zone: 'America/Toronto', offsetHours: -4, offsetMinutes: 0, flag: '🇨🇦' },
    { id: 'vancouver', name: '温哥华', zone: 'America/Vancouver', offsetHours: -7, offsetMinutes: 0, flag: '🇨🇦' },
    { id: 'saopaulo', name: '圣保罗', zone: 'America/Sao_Paulo', offsetHours: -3, offsetMinutes: 0, flag: '🇧🇷' },
    { id: 'sydney', name: '悉尼', zone: 'Australia/Sydney', offsetHours: 10, offsetMinutes: 0, flag: '🇦🇺' },
    { id: 'melbourne', name: '墨尔本', zone: 'Australia/Melbourne', offsetHours: 10, offsetMinutes: 0, flag: '🇦🇺' },
    { id: 'auckland', name: '奥克兰', zone: 'Pacific/Auckland', offsetHours: 12, offsetMinutes: 0, flag: '🇳🇿' },
    { id: 'honolulu', name: '檀香山', zone: 'Pacific/Honolulu', offsetHours: -10, offsetMinutes: 0, flag: '🇺🇸' },
  ];

  /**
   * 获取某个城市的当前时间字符串
   */
  static getCityTime(city: CityTime): { time: string; date: string } {
    const now = new Date();
    // 使用本地 UTC 时间 + 偏移量计算目标城市时间
    const localUtc = now.getTime() + now.getTimezoneOffset() * 60 * 1000;
    const targetTime = localUtc + (city.offsetHours * 60 + city.offsetMinutes) * 60 * 1000;
    const targetDate = new Date(targetTime);

    const h = String(targetDate.getHours()).padStart(2, '0');
    const m = String(targetDate.getMinutes()).padStart(2, '0');
    const s = String(targetDate.getSeconds()).padStart(2, '0');
    const time = `${h}:${m}:${s}`;

    const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const month = months[targetDate.getMonth()];
    const day = targetDate.getDate();
    const weekday = weekdays[targetDate.getDay()];
    const date = `${month}${day}日 ${weekday}`;

    return { time: time, date: date };
  }

  /**
   * 获取偏移字符串（如 "+08:00" 或 "+05:30"）
   */
  static getOffsetString(city: CityTime): string {
    const sign = city.offsetHours >= 0 ? '+' : '';
    const absH = Math.abs(city.offsetHours);
    if (city.offsetMinutes === 0) {
      return `${sign}${absH}`;
    }
    return `${sign}${absH}:${String(Math.abs(city.offsetMinutes)).padStart(2, '0')}`;
  }

  static getCityById(id: string): CityTime | undefined {
    return WorldClockData.CITIES.find((c) => c.id === id);
  }
}
