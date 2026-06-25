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
  @State cityTimes: Map<string, { time: string; date: string }> = new Map();
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
        // 默认：北京、东京、伦敦、纽约
        this.selectedCities = [
          WorldClockData.getCityById('beijing')!,
          WorldClockData.getCityById('tokyo')!,
          WorldClockData.getCityById('london')!,
          WorldClockData.getCityById('newyork')!,
        ];
      }
    } catch (e) {
      // 默认值
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
      this.cityTimes.set(city.id, result);
    }
    // 触发 UI 更新
    this.cityTimes = new Map(this.cityTimes);
  }

  build() {
    Column({ space: 3 }) {
      Text('世界时钟')
        .fontSize(11)
        .fontColor(this.theme.subTextColor)
        .margin({ bottom: 2 });

      ForEach(this.selectedCities.slice(0, 3), (city: CityTime) => {
        Row({ space: 4 }) {
          Text(city.flag)
            .fontSize(12);

          Text(city.name)
            .fontSize(12)
            .fontColor(this.theme.subTextColor)
            .layoutWeight(1);

          Text(this.cityTimes.get(city.id)?.time ?? '--:--:--')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.theme.textColor)
            .fontFamily('monospace');
        }
        .width('100%')
        .padding({ left: 4, right: 4 });
      }, (city: CityTime) => city.id);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}
