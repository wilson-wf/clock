import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FloatingWindowManager } from '../utils/FloatingWindowManager';
import { ThemeManager, ThemeStyle } from '../model/Theme';
import { TimeFormatter } from '../utils/TimeFormatter';
import { WorldClockData, CityTime } from '../model/WorldClock';
import type { DisplayMode } from './FloatingClock';

@Entry
@Component
struct Index {
  @State currentTheme: string = 'dark';
  @State currentMode: DisplayMode = 'clock';
  @State showDate: boolean = true;
  @State countdownMinutes: number = 5;
  @State countdownTotal: number = 300;
  @State isFloatingShown: boolean = false;
  @State previewTime: string = '00:00:00';
  @State previewDate: string = '';

  // 番茄钟
  @State pomodoroWorkMin: number = 25;
  @State pomodoroBreakMin: number = 5;
  @State pomodoroLongBreakMin: number = 15;
  @State pomodoroRounds: number = 4;

  // 闹钟
  @State alarmHour: number = 0;
  @State alarmMinute: number = 0;
  @State alarmEnabled: boolean = false;
  @State showAlarmPicker: boolean = false;

  // 透明度
  @State windowOpacity: number = 75;

  // 世界时钟
  @State selectedCityIds: string = 'beijing,tokyo,london,newyork';
  @State showCityPicker: boolean = false;

  private timerId: number = -1;

  aboutToAppear(): void {
    this.loadPreferences();
    this.updatePreviewTime();
    this.timerId = setInterval(() => this.updatePreviewTime(), 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) clearInterval(this.timerId);
  }

  private async loadPreferences(): Promise<void> {
    this.currentTheme = await PreferencesUtil.getTheme();
    this.currentMode = (await PreferencesUtil.getMode()) as DisplayMode;
    this.showDate = await PreferencesUtil.getShowDate();
    this.countdownTotal = await PreferencesUtil.getCountdownSeconds();
    this.countdownMinutes = Math.floor(this.countdownTotal / 60);
    this.isFloatingShown = FloatingWindowManager.getInstance().isWindowShown();
    this.pomodoroWorkMin = await PreferencesUtil.getPomodoroWorkMinutes();
    this.pomodoroBreakMin = await PreferencesUtil.getPomodoroBreakMinutes();
    this.pomodoroLongBreakMin = await PreferencesUtil.getPomodoroLongBreakMinutes();
    this.pomodoroRounds = await PreferencesUtil.getPomodoroRounds();
    const alarmTime = await PreferencesUtil.getAlarmTime();
    this.alarmHour = alarmTime.hour;
    this.alarmMinute = alarmTime.minute;
    this.alarmEnabled = await PreferencesUtil.getAlarmEnabled();
    this.windowOpacity = await PreferencesUtil.getWindowOpacity();
  }

  private updatePreviewTime(): void {
    const now = new Date();
    const result = TimeFormatter.formatClock(now);
    this.previewTime = result.time;
    this.previewDate = result.date;
  }

  private getTheme(): ThemeStyle {
    return ThemeManager.getTheme(this.currentTheme);
  }

  private async selectTheme(name: string): Promise<void> {
    this.currentTheme = name;
    await PreferencesUtil.setTheme(name);
  }

  private async selectMode(mode: DisplayMode): Promise<void> {
    this.currentMode = mode;
    await PreferencesUtil.setMode(mode);
  }

  private async toggleShowDate(): Promise<void> {
    this.showDate = !this.showDate;
    await PreferencesUtil.setShowDate(this.showDate);
  }

  private async onCountdownMinutesChanged(value: number): Promise<void> {
    this.countdownMinutes = Math.floor(value);
    this.countdownTotal = this.countdownMinutes * 60;
    await PreferencesUtil.setCountdownSeconds(this.countdownTotal);
  }

  private async showFloatingWindow(): Promise<void> {
    const pos = await PreferencesUtil.getWindowPosition();
    const ok = await FloatingWindowManager.getInstance().createFloatingWindow(240, 140, pos.x, pos.y);
    this.isFloatingShown = ok;
  }

  private async hideFloatingWindow(): Promise<void> {
    await FloatingWindowManager.getInstance().hideFloatingWindow();
    this.isFloatingShown = false;
  }

  private async setAlarm(): Promise<void> {
    await PreferencesUtil.setAlarmTime(this.alarmHour, this.alarmMinute);
    await PreferencesUtil.setAlarmEnabled(true);
    this.alarmEnabled = true;
    this.showAlarmPicker = false;
  }

  private async toggleAlarm(): Promise<void> {
    this.alarmEnabled = !this.alarmEnabled;
    await PreferencesUtil.setAlarmEnabled(this.alarmEnabled);
  }

  private async onOpacityChanged(value: number): Promise<void> {
    this.windowOpacity = Math.floor(value);
    await PreferencesUtil.setWindowOpacity(this.windowOpacity);
  }

  private async onPomodoroWorkChanged(value: number): Promise<void> {
    this.pomodoroWorkMin = Math.floor(value);
    await PreferencesUtil.setPomodoroWorkMinutes(this.pomodoroWorkMin);
  }

  private async onPomodoroBreakChanged(value: number): Promise<void> {
    this.pomodoroBreakMin = Math.floor(value);
    await PreferencesUtil.setPomodoroBreakMinutes(this.pomodoroBreakMin);
  }

  private async onPomodoroLongBreakChanged(value: number): Promise<void> {
    this.pomodoroLongBreakMin = Math.floor(value);
    await PreferencesUtil.setPomodoroLongBreakMinutes(this.pomodoroLongBreakMin);
  }

  private async onPomodoroRoundsChanged(value: number): Promise<void> {
    this.pomodoroRounds = Math.floor(value);
    await PreferencesUtil.setPomodoroRounds(this.pomodoroRounds);
  }

  private getSelectedCities(): CityTime[] {
    return this.selectedCityIds.split(',').map((id) => WorldClockData.getCityById(id.trim())).filter((c): c is CityTime => c !== undefined);
  }

  private async toggleCity(cityId: string): Promise<void> {
    const ids = this.selectedCityIds.split(',').map((s) => s.trim()).filter((s) => s.length > 0);
    const idx = ids.indexOf(cityId);
    if (idx >= 0) {
      ids.splice(idx, 1);
    } else {
      if (ids.length < 4) ids.push(cityId);
    }
    this.selectedCityIds = ids.join(',');
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('悬浮时钟')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ top: 40, bottom: 8 });

        Text('支持桌面小组件 · 多模式 · 多主题')
          .fontSize(13)
          .fontColor('#888888')
          .margin({ bottom: 24 });

        // 预览卡片
        this.buildPreviewCard();

        // 主题选择
        this.buildSection('🎨 主题选择', () => this.buildThemeGrid());

        // 模式选择
        this.buildSection('📋 显示模式', () => this.buildModeButtons());

        // 倒计时配置
        if (this.currentMode === 'countdown') {
          this.buildSection('⏱ 倒计时设置', () => this.buildCountdownConfig());
        }

        // 番茄钟配置
        if (this.currentMode === 'pomodoro') {
          this.buildSection('🍅 番茄钟设置', () => this.buildPomodoroConfig());
        }

        // 世界时钟
        if (this.currentMode === 'worldclock') {
          this.buildSection('🌍 世界时钟城市', () => this.buildWorldClockConfig());
        }

        // 日期显示
        Row() {
          Text('显示日期')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .layoutWeight(1);
          Toggle({ type: ToggleType.Switch, isOn: this.showDate })
            .selectedColor('#4FC3F7')
            .switchPointColor('#FFFFFF')
            .onChange(() => this.toggleShowDate());
        }
        .width('90%')
        .margin({ bottom: 20 });

        // 闹钟设置
        this.buildSection('🔔 闹钟设置', () => this.buildAlarmConfig());

        // 透明度设置
        this.buildSection('🔲 窗口透明度', () => this.buildOpacityConfig());

        // 显示/隐藏悬浮窗
        if (this.isFloatingShown) {
          Button('隐藏悬浮窗')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B6B')
            .width('90%')
            .height(52)
            .borderRadius(26)
            .margin({ bottom: 20 })
            .onClick(() => this.hideFloatingWindow());
        } else {
          Button('显示悬浮窗')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#4FC3F7')
            .width('90%')
            .height(52)
            .borderRadius(26)
            .margin({ bottom: 20 })
            .onClick(() => this.showFloatingWindow());
        }

        // 使用提示
        this.buildTips();
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .scrollBarWidth(4)
    .backgroundColor('#1A1A1A');
  }

  @Builder
  buildPreviewCard() {
    Column() {
      Text(this.previewTime)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTheme().textColor)
        .fontFamily('monospace')
        .letterSpacing(2);
      if (this.showDate) {
        Text(this.previewDate)
          .fontSize(14)
          .fontColor(this.getTheme().subTextColor)
          .margin({ top: 4 });
      }
    }
    .width('90%')
    .height(130)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.getTheme().bgColor)
    .borderRadius(16)
    .border({ width: 1, color: this.getTheme().borderColor })
    .shadow({ radius: 16, color: this.getTheme().shadowColor, offsetX: 2, offsetY: 6 })
    .margin({ bottom: 28 });
  }

  @Builder
  buildSection(title: string, contentBuilder: () => void) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('90%')
        .margin({ bottom: 10 });
      contentBuilder();
    }
    .width('100%')
    .margin({ bottom: 24 });
  }

  @Builder
  buildThemeGrid() {
    Grid() {
      ForEach(ThemeManager.THEMES, (theme: ThemeStyle) => {
        GridItem() {
          Column({ space: 4 }) {
            Text('12:34')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(theme.textColor);
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor(theme.bgColor)
          .borderRadius(12)
          .border({
            width: this.currentTheme === theme.name ? 3 : 1,
            color: this.currentTheme === theme.name ? '#4FC3F7' : theme.borderColor
          });
          Text(theme.label)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .margin({ top: 4 });
        }
        .height(80)
        .onClick(() => this.selectTheme(theme.name));
      }, (theme: ThemeStyle) => theme.name);
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .width('90%')
    .height(190)
    .margin({ bottom: 4 });
  }

  @Builder
  buildModeButtons() {
    Row({ space: 8 }) {
      ForEach(['clock', 'countdown', 'stopwatch', 'pomodoro', 'worldclock'] as DisplayMode[], (mode: DisplayMode) => {
        Button(this.getModeShortLabel(mode))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.currentMode === mode ? '#4FC3F7' : '#3A3A3A')
          .height(40)
          .layoutWeight(1)
          .borderRadius(8)
          .onClick(() => this.selectMode(mode));
      }, (mode: DisplayMode) => mode);
    }
    .width('90%');
  }

  private getModeShortLabel(mode: DisplayMode): string {
    const labels: Record<DisplayMode, string> = {
      'clock': '时钟',
      'countdown': '倒计时',
      'stopwatch': '秒表',
      'pomodoro': '番茄',
      'worldclock': '世界'
    };
    return labels[mode];
  }

  @Builder
  buildCountdownConfig() {
    Column() {
      Row() {
        Text(`倒计时 ${this.countdownMinutes} 分钟`)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .layoutWeight(1);
      }
      .width('90%')
      .margin({ bottom: 8 });
      Slider({
        value: this.countdownMinutes,
        min: 1,
        max: 60,
        step: 1,
        style: SliderStyle.OutSet
      })
        .blockColor('#4FC3F7')
        .selectedColor('#4FC3F7')
        .trackColor('#555555')
        .onChange((v: number) => this.onCountdownMinutesChanged(v));
    }
    .width('100%');
  }

  @Builder
  buildPomodoroConfig() {
    Column({ space: 16 }) {
      Row() {
        Text(`工作时长 ${this.pomodoroWorkMin} 分钟`)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .layoutWeight(1);
        Text(`短休息 ${this.pomodoroBreakMin} 分钟`)
          .fontSize(13)
          .fontColor('#FFFFFF');
      }
      .width('90%');

      Row() {
        Slider({
          value: this.pomodoroWorkMin, min: 5, max: 60, step: 1, style: SliderStyle.OutSet
        })
          .blockColor('#E57373').selectedColor('#E57373').trackColor('#555555')
          .layoutWeight(1)
          .onChange((v: number) => this.onPomodoroWorkChanged(v));
        Slider({
          value: this.pomodoroBreakMin, min: 1, max: 30, step: 1, style: SliderStyle.OutSet
        })
          .blockColor('#81C784').selectedColor('#81C784').trackColor('#555555')
          .layoutWeight(1)
          .onChange((v: number) => this.onPomodoroBreakChanged(v));
      }
      .width('90%')
      .columnsGap(12);

      Row() {
        Text(`长休息 ${this.pomodoroLongBreakMin} 分钟`)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .layoutWeight(1);
        Text(`轮数 ${this.pomodoroRounds}`)
          .fontSize(13)
          .fontColor('#FFFFFF');
      }
      .width('90%');

      Row() {
        Slider({
          value: this.pomodoroLongBreakMin, min: 5, max: 60, step: 1, style: SliderStyle.OutSet
        })
          .blockColor('#64B5F6').selectedColor('#64B5F6').trackColor('#555555')
          .layoutWeight(1)
          .onChange((v: number) => this.onPomodoroLongBreakChanged(v));
        Slider({
          value: this.pomodoroRounds, min: 1, max: 8, step: 1, style: SliderStyle.OutSet
        })
          .blockColor('#FFB74D').selectedColor('#FFB74D').trackColor('#555555')
          .layoutWeight(1)
          .onChange((v: number) => this.onPomodoroRoundsChanged(v));
      }
      .width('90%')
      .columnsGap(12);
    }
    .width('100%');
  }

  @Builder
  buildWorldClockConfig() {
    Column() {
      Text('已选城市（最多 4 个）')
        .fontSize(13)
        .fontColor('#888888')
        .width('90%')
        .margin({ bottom: 8 });

      ForEach(this.getSelectedCities(), (city: CityTime) => {
        Row() {
          Text(`${city.flag} ${city.name}`)
            .fontSize(13)
            .fontColor(this.getTheme().textColor)
            .layoutWeight(1);
          Text(`${city.offsetHours >= 0 ? '+' : ''}${city.offsetHours}:${String(Math.abs(city.offsetMinutes)).padStart(2, '0')}`)
            .fontSize(12)
            .fontColor(this.getTheme().subTextColor);
        }
        .width('90%')
        .padding({ top: 4, bottom: 4 });
      }, (city: CityTime) => city.id);

      Text('可选城市')
        .fontSize(13)
        .fontColor('#888888')
        .width('90%')
        .margin({ top: 12, bottom: 8 });

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(WorldClockData.CITIES, (city: CityTime) => {
          Text(`${city.flag} ${city.name}`)
            .fontSize(12)
            .fontColor(this.selectedCityIds.includes(city.id) ? '#4FC3F7' : '#888888')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.selectedCityIds.includes(city.id) ? 'rgba(79,195,247,0.2)' : 'rgba(255,255,255,0.05)')
            .borderRadius(6)
            .margin({ right: 6, bottom: 4 })
            .onClick(() => this.toggleCity(city.id));
        }, (city: CityTime) => city.id);
      }
      .width('90%');
    }
    .width('100%');
  }

  @Builder
  buildAlarmConfig() {
    Row() {
      Text(`闹钟 ${String(this.alarmHour).padStart(2, '0')}:${String(this.alarmMinute).padStart(2, '0')}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF');

      Row({ space: 12 }) {
        if (this.showAlarmPicker) {
          Row({ space: 4 }) {
            Text('时')
              .fontSize(12)
              .fontColor('#888888');
            TextInput({ text: String(this.alarmHour) })
              .width(48)
              .height(36)
              .type(InputType.Number)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .backgroundColor('#2A2A2A')
              .borderRadius(6)
              .onChange((v: string) => {
                const h = Math.max(0, Math.min(23, parseInt(v) || 0));
                this.alarmHour = h;
              });

            Text('分')
              .fontSize(12)
              .fontColor('#888888');
            TextInput({ text: String(this.alarmMinute) })
              .width(48)
              .height(36)
              .type(InputType.Number)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .backgroundColor('#2A2A2A')
              .borderRadius(6)
              .onChange((v: string) => {
                const m = Math.max(0, Math.min(59, parseInt(v) || 0));
                this.alarmMinute = m;
              });

            Text('确定')
              .fontSize(13)
              .fontColor('#4FC3F7')
              .padding({ left: 8, right: 8 })
              .onClick(() => this.setAlarm());
          }
        } else {
          Button('设置闹钟')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('#3A3A3A')
            .height(36)
            .borderRadius(8)
            .onClick(() => this.showAlarmPicker = true);
        }

        Toggle({ type: ToggleType.Switch, isOn: this.alarmEnabled })
          .selectedColor('#4FC3F7')
          .switchPointColor('#FFFFFF')
          .onChange(() => this.toggleAlarm());
      }
    }
    .width('90%')
    .margin({ bottom: 8 });
  }

  @Builder
  buildOpacityConfig() {
    Row() {
      Text(`${this.windowOpacity}%`)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .margin({ right: 12 });
      Slider({
        value: this.windowOpacity,
        min: 20,
        max: 100,
        step: 5,
        style: SliderStyle.OutSet
      })
        .blockColor('#4FC3F7')
        .selectedColor('#4FC3F7')
        .trackColor('#555555')
        .layoutWeight(1)
        .onChange((v: number) => this.onOpacityChanged(v));
    }
    .width('90%');
  }

  @Builder
  buildTips() {
    Column({ space: 4 }) {
      Text('💡 使用提示').fontSize(14).fontColor('#888888').width('90%').margin({ top: 16, bottom: 8 });
      Text('• 悬浮窗内长按可打开设置菜单').fontSize(12).fontColor('#666666').width('90%');
      Text('• 单击可启动/暂停倒计时、秒表、番茄钟').fontSize(12).fontColor('#666666').width('90%');
      Text('• 拖动悬浮窗可自由改变位置').fontSize(12).fontColor('#666666').width('90%');
      Text('• 番茄钟：工作→短休息→...→长休息循环').fontSize(12).fontColor('#666666').width('90%');
      Text('• 世界时钟自动计算各城市当前时间').fontSize(12).fontColor('#666666').width('90%');
    }
    .width('100%')
    .margin({ bottom: 50 });
  }
}
