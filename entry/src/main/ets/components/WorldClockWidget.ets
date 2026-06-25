/**
 * 世界时钟组件
 * 显示用户选择的城市时区列表，每秒刷新
 */
import { CityTime, WorldClockData } from '../model/WorldClock';
import { ThemeStyle } from '../model/Theme';
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

const PREFS_FILE = 'world_clock_prefs';
const KEY_CITY_IDS = 'selected_city_ids';

@Component
export struct WorldClockWidget {
  @Prop theme: ThemeStyle;
  @State selectedCities: CityTime[] = [];
  @State cityTimes: Map<string, { time: string; date: string; isDay: boolean }> = new Map();
  private timerId: number = -1;
  private context: Context | null = null;

  aboutToAppear(): Promise<void> {
    this.context = getContext(this) as Context;
    this.loadSelectedCities();
    this.updateTimes();
    this.timerId = setInterval(() => {
      this.updateTimes();
    }, 1000);
    return Promise.resolve();
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private async loadSelectedCities(): Promise<void> {
    if (!this.context) return;
    try {
      const prefs = await preferences.getPreferences(this.context, PREFS_FILE);
      const idsStr = await prefs.get(KEY_CITY_IDS, 'beijing,tokyo,london,newyork') as string;
      const ids = idsStr.split(',');
      this.selectedCities = ids
        .map((id) => WorldClockData.getCityById(id.trim()))
        .filter((c): c is CityTime => c !== undefined);
      if (this.selectedCities.length === 0) {
        this.selectedCities = [
          WorldClockData.getCityById('beijing')!,
          WorldClockData.getCityById('tokyo')!,
          WorldClockData.getCityById('london')!,
          WorldClockData.getCityById('newyork')!,
        ];
      }
    } catch (e) {
      this.selectedCities = [
        WorldClockData.getCityById('beijing')!,
        WorldClockData.getCityById('tokyo')!,
        WorldClockData.getCityById('london')!,
        WorldClockData.getCityById('newyork')!,
      ];
    }
  }

  private updateTimes(): void {
    for (const city of this.selectedCities) {
      const result = WorldClockData.getCityTime(city);
      const hour = parseInt(result.time.split(':')[0]);
      const isDay = hour >= 6 && hour < 18;
      this.cityTimes.set(city.id, { ...result, isDay });
    }
    this.cityTimes = new Map(this.cityTimes);
  }

  private getDayNightIcon(isDay: boolean): string {
    return isDay ? '☀️' : '🌙';
  }

  build() {
    Column({ space: 4 }) {
      // 标题
      Row({ space: 4 }) {
        Text('🌍')
          .fontSize(11);
        Text('世界时钟')
          .fontSize(11)
          .fontColor(this.theme.colors.textSecondary);
      }
      .margin({ bottom: 2 });

      // 城市列表
      ForEach(this.selectedCities.slice(0, 3), (city: CityTime) => {
        Row({ space: 6 }) {
          // 日夜图标
          Text(this.getDayNightIcon(this.cityTimes.get(city.id)?.isDay ?? true))
            .fontSize(10)
            .width(14);

          // 城市信息
          Column({ space: 0 }) {
            Text(city.name)
              .fontSize(11)
              .fontColor(this.theme.colors.textSecondary);
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1);

          // 时间
          Text(this.cityTimes.get(city.id)?.time ?? '--:--')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.theme.colors.textPrimary)
            .fontFamily('monospace');
        }
        .width('100%')
        .padding({ left: 4, right: 4, top: 3, bottom: 3 })
        .borderRadius(6)
        .backgroundColor(this.theme.colors.bgSecondary);
      }, (city: CityTime) => city.id);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}
