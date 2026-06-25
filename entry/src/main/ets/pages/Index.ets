import { PreferencesUtil } from '../utils/PreferencesUtil';
import { FloatingWindowManager } from '../utils/FloatingWindowManager';
import { ThemeManager, ThemeStyle } from '../model/Theme';
import { TimeFormatter } from '../utils/TimeFormatter';
import { WorldClockData, CityTime } from '../model/WorldClock';
import type { DisplayMode } from './FloatingClock';

@Entry
@Component
struct Index {
  @State currentTheme: string = 'harmony_dark';
  @State currentMode: DisplayMode = 'clock';
  @State showDate: boolean = true;
  @State countdownMinutes: number = 5;
  @State countdownTotal: number = 300;
  @State isFloatingShown: boolean = false;
  @State previewTime: string = '00:00:00';
  @State previewDate: string = '';

  @State pomodoroWorkMin: number = 25;
  @State pomodoroBreakMin: number = 5;
  @State pomodoroLongBreakMin: number = 15;
  @State pomodoroRounds: number = 4;

  @State alarmHour: number = 0;
  @State alarmMinute: number = 0;
  @State alarmEnabled: boolean = false;
  @State showAlarmPicker: boolean = false;

  @State windowOpacity: number = 75;

  @State selectedCityIds: string = 'beijing,tokyo,london,newyork';

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
    const savedTheme = await PreferencesUtil.getTheme();
    const existing = ThemeManager.THEMES.find(t => t.name === savedTheme);
    this.currentTheme = existing ? savedTheme : 'harmony_dark';
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

  private getBg(): string {
    return this.getTheme().colors.bgPrimary;
  }

  private getCardBg(): string {
    return this.getTheme().colors.bgElevated;
  }

  private getTextPrimary(): string {
    return this.getTheme().colors.textPrimary;
  }

  private getTextSecondary(): string {
    return this.getTheme().colors.textSecondary;
  }

  private getBorder(): string {
    return this.getTheme().colors.borderColor;
  }

  private getDivider(): string {
    return this.getTheme().colors.dividerColor;
  }

  private getPrimary(): string {
    return this.getTheme().colors.primary;
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
    const ok = await FloatingWindowManager.getInstance().createFloatingWindow(240, 150, pos.x, pos.y);
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

  private getModeIcon(mode: DisplayMode): string {
    const icons: Record<DisplayMode, string> = {
      'clock': '🕐',
      'countdown': '⏱️',
      'stopwatch': '⏲️',
      'pomodoro': '🍅',
      'worldclock': '🌍'
    };
    return icons[mode];
  }

  private getModeLabel(mode: DisplayMode): string {
    const labels: Record<DisplayMode, string> = {
      'clock': '时钟',
      'countdown': '倒计时',
      'stopwatch': '秒表',
      'pomodoro': '番茄',
      'worldclock': '世界'
    };
    return labels[mode];
  }

  build() {
    Stack() {
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getBg());

      Scroll() {
        Column({ space: 16 }) {
          this.buildHeader();
          this.buildHeroPreview();
          this.buildModeSelector();
          this.buildThemeSection();
          this.buildSettingsCard();

          if (this.currentMode === 'countdown') {
            this.buildCountdownCard();
          }
          if (this.currentMode === 'pomodoro') {
            this.buildPomodoroCard();
          }
          if (this.currentMode === 'worldclock') {
            this.buildWorldClockCard();
          }

          this.buildAlarmCard();
          this.buildOpacityCard();
          this.buildActionButton();
          this.buildTips();
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 40 });
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off);
    }
    .width('100%')
    .height('100%');
  }

  // === 头部 ===
  @Builder
  buildHeader() {
    Row() {
      Column({ space: 2 }) {
        Text('悬浮时钟')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextPrimary());
        Text('桌面悬浮 · 多模式切换 · 精致体验')
          .fontSize(12)
          .fontColor(this.getTextSecondary());
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      Column() {
        Text('⏰')
          .fontSize(36);
      }
      .width(56)
      .height(56)
      .backgroundColor(this.getCardBg())
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({ radius: 8, color: this.getTheme().shadowColor, offsetX: 0, offsetY: 2 });
    }
    .width('100%')
    .padding({ top: 48, bottom: 8 });
  }

  // === 预览卡片 ===
  @Builder
  buildHeroPreview() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 6 }) {
        Text(this.previewTime)
          .fontSize(42)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTheme().textColor)
          .fontFamily('HarmonyOS Sans, monospace')
          .letterSpacing(3);

        if (this.showDate) {
          Text(this.previewDate)
            .fontSize(14)
            .fontColor(this.getTheme().subTextColor);
        }

        Row({ space: 8 }) {
          Text(this.getModeIcon(this.currentMode))
            .fontSize(14);
          Text(this.getModeLabel(this.currentMode) + '模式')
            .fontSize(12)
            .fontColor(this.getTheme().subTextColor);
        }
        .margin({ top: 8 })
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(this.getTheme().borderColor)
        .borderRadius(100);
      }
      .padding({ left: 24, right: 24, top: 24, bottom: 24 });
    }
    .width('100%')
    .backgroundColor(this.getTheme().bgColor)
    .borderRadius(24)
    .border({ width: 1, color: this.getTheme().borderColor })
    .shadow({
      radius: 20,
      color: this.getTheme().shadowColor,
      offsetX: 0,
      offsetY: 8
    });
  }

  // === 模式选择器 ===
  @Builder
  buildModeSelector() {
    Row({ space: 8 }) {
      ForEach(['clock', 'countdown', 'stopwatch', 'pomodoro', 'worldclock'] as DisplayMode[], (mode: DisplayMode) => {
        Column({ space: 4 }) {
          Text(this.getModeIcon(mode))
            .fontSize(20);
          Text(this.getModeLabel(mode))
            .fontSize(11)
            .fontColor(this.currentMode === mode ? this.getPrimary() : this.getTextSecondary());
        }
        .layoutWeight(1)
        .height(68)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.currentMode === mode ? this.getCardBg() : 'transparent')
        .borderRadius(14)
        .border({
          width: this.currentMode === mode ? 1.5 : 0,
          color: this.currentMode === mode ? this.getPrimary() : 'transparent'
        })
        .onClick(() => this.selectMode(mode));
      }, (mode: DisplayMode) => mode);
    }
    .width('100%')
    .padding(6)
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  // === 主题选择 ===
  @Builder
  buildThemeSection() {
    Column({ space: 12 }) {
      this.buildSectionTitle('🎨 主题风格');

      Grid() {
        ForEach(ThemeManager.THEMES, (theme: ThemeStyle, index: number) => {
          GridItem() {
            Column({ space: 6 }) {
              Row() {
                Text('12:34')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(theme.textColor);
              }
              .width('100%')
              .height(52)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(theme.bgColor)
              .borderRadius(10)
              .border({
                width: this.currentTheme === theme.name ? 2 : 1,
                color: this.currentTheme === theme.name ? this.getPrimary() : theme.borderColor
              });

              Text(theme.label)
                .fontSize(11)
                .fontColor(this.getTextSecondary());
            }
            .width('100%')
            .onClick(() => this.selectTheme(theme.name));
          }
        }, (theme: ThemeStyle) => theme.name);
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(10)
      .width('100%');
    }
    .width('100%');
  }

  // === 设置卡片 ===
  @Builder
  buildSettingsCard() {
    Column() {
      this.buildListRow('📅', '显示日期', this.showDate, true, () => this.toggleShowDate());
      this.buildDivider();
      this.buildListRow('🪟', '桌面小组件', false, false, undefined, '长按桌面添加');
    }
    .width('100%')
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  // === 倒计时卡片 ===
  @Builder
  buildCountdownCard() {
    Column({ space: 14 }) {
      this.buildSectionTitle('⏱️ 倒计时设置');

      Row() {
        Text(`${this.countdownMinutes} 分钟`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTextPrimary())
          .layoutWeight(1);
        Text('1-60 min')
          .fontSize(12)
          .fontColor(this.getTextSecondary());
      }
      .width('100%');

      Slider({
        value: this.countdownMinutes,
        min: 1,
        max: 60,
        step: 1,
        style: SliderStyle.OutSet
      })
        .blockColor(this.getPrimary())
        .selectedColor(this.getPrimary())
        .trackColor(this.getBorder())
        .blockSize(20)
        .trackThickness(6)
        .onChange((v: number) => this.onCountdownMinutesChanged(v));
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  // === 番茄钟卡片 ===
  @Builder
  buildPomodoroCard() {
    Column({ space: 16 }) {
      this.buildSectionTitle('🍅 番茄钟设置');

      // 工作 + 短休息
      Row({ space: 16 }) {
        Column({ space: 6 }) {
          this.buildStatItem('工作', `${this.pomodoroWorkMin}min`, '#F87171');
          Slider({ value: this.pomodoroWorkMin, min: 5, max: 60, step: 1, style: SliderStyle.InSet })
            .blockColor('#F87171').selectedColor('#F87171').trackColor(this.getBorder())
            .blockSize(16).trackThickness(4)
            .onChange((v: number) => this.onPomodoroWorkChanged(v));
        }
        .layoutWeight(1);

        Column({ space: 6 }) {
          this.buildStatItem('短休', `${this.pomodoroBreakMin}min`, '#4ADE80');
          Slider({ value: this.pomodoroBreakMin, min: 1, max: 30, step: 1, style: SliderStyle.InSet })
            .blockColor('#4ADE80').selectedColor('#4ADE80').trackColor(this.getBorder())
            .blockSize(16).trackThickness(4)
            .onChange((v: number) => this.onPomodoroBreakChanged(v));
        }
        .layoutWeight(1);
      }
      .width('100%');

      // 长休息 + 轮数
      Row({ space: 16 }) {
        Column({ space: 6 }) {
          this.buildStatItem('长休', `${this.pomodoroLongBreakMin}min`, '#60A5FA');
          Slider({ value: this.pomodoroLongBreakMin, min: 5, max: 60, step: 1, style: SliderStyle.InSet })
            .blockColor('#60A5FA').selectedColor('#60A5FA').trackColor(this.getBorder())
            .blockSize(16).trackThickness(4)
            .onChange((v: number) => this.onPomodoroLongBreakChanged(v));
        }
        .layoutWeight(1);

        Column({ space: 6 }) {
          this.buildStatItem('轮数', `${this.pomodoroRounds}轮`, '#FBBF24');
          Slider({ value: this.pomodoroRounds, min: 1, max: 8, step: 1, style: SliderStyle.InSet })
            .blockColor('#FBBF24').selectedColor('#FBBF24').trackColor(this.getBorder())
            .blockSize(16).trackThickness(4)
            .onChange((v: number) => this.onPomodoroRoundsChanged(v));
        }
        .layoutWeight(1);
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  @Builder
  buildStatItem(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(this.getTextSecondary())
        .layoutWeight(1);
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(color);
    }
    .width('100%');
  }

  // === 世界时钟卡片 ===
  @Builder
  buildWorldClockCard() {
    Column({ space: 12 }) {
      this.buildSectionTitle('🌍 世界时钟（最多4个）');

      ForEach(this.getSelectedCities(), (city: CityTime) => {
        Row() {
          Text(city.flag)
            .fontSize(18)
            .margin({ right: 8 });

          Column({ space: 2 }) {
            Text(city.name)
              .fontSize(14)
              .fontColor(this.getTextPrimary());
            Text(`${city.offsetHours >= 0 ? 'UTC+' : 'UTC'}${city.offsetHours}:${String(Math.abs(city.offsetMinutes)).padStart(2, '0')}`)
              .fontSize(11)
              .fontColor(this.getTextSecondary());
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1);

          Text('✓')
            .fontSize(14)
            .fontColor(this.getPrimary());
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .onClick(() => this.toggleCity(city.id));
      }, (city: CityTime) => city.id);

      this.buildDivider();

      Text('添加更多城市')
        .fontSize(12)
        .fontColor(this.getTextSecondary())
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 4, bottom: 4 });

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(WorldClockData.CITIES, (city: CityTime) => {
          if (this.selectedCityIds.includes(city.id)) {
            return;
          }
          Text(`${city.flag} ${city.name}`)
            .fontSize(12)
            .fontColor(this.getTextPrimary())
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(this.getBg())
            .borderRadius(8)
            .margin({ right: 6, bottom: 6 })
            .onClick(() => this.toggleCity(city.id));
        }, (city: CityTime) => city.id);
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  // === 闹钟卡片 ===
  @Builder
  buildAlarmCard() {
    Column({ space: 14 }) {
      this.buildSectionTitle('🔔 闹钟');

      Row() {
        Row({ space: 6 }) {
          Text('⏰')
            .fontSize(20);
          Text(`${String(this.alarmHour).padStart(2, '0')}:${String(this.alarmMinute).padStart(2, '0')}`)
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getTextPrimary());
        }
        .layoutWeight(1);

        Toggle({ type: ToggleType.Switch, isOn: this.alarmEnabled })
          .selectedColor(this.getPrimary())
          .switchPointColor('#FFFFFF')
          .onChange(() => this.toggleAlarm());
      }
      .width('100%');

      if (this.showAlarmPicker) {
        Row({ space: 10 }) {
          TextInput({ text: String(this.alarmHour) })
            .layoutWeight(1)
            .height(44)
            .type(InputType.Number)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.getBg())
            .borderRadius(10)
            .onChange((v: string) => {
              const h = Math.max(0, Math.min(23, parseInt(v) || 0));
              this.alarmHour = h;
            });

          Text(':')
            .fontSize(20)
            .fontColor(this.getTextSecondary());

          TextInput({ text: String(this.alarmMinute) })
            .layoutWeight(1)
            .height(44)
            .type(InputType.Number)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.getBg())
            .borderRadius(10)
            .onChange((v: string) => {
              const m = Math.max(0, Math.min(59, parseInt(v) || 0));
              this.alarmMinute = m;
            });

          Button('保存')
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getPrimary())
            .height(44)
            .borderRadius(10)
            .onClick(() => this.setAlarm());
        }
        .width('100%');
      } else {
        Text('修改时间')
          .fontSize(13)
          .fontColor(this.getPrimary())
          .onClick(() => {
            this.showAlarmPicker = true;
          });
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  // === 透明度卡片 ===
  @Builder
  buildOpacityCard() {
    Column({ space: 14 }) {
      this.buildSectionTitle('🔲 窗口透明度');

      Row() {
        Text(`${this.windowOpacity}%`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTextPrimary())
          .layoutWeight(1);
        Text('20% - 100%')
          .fontSize(12)
          .fontColor(this.getTextSecondary());
      }
      .width('100%');

      Slider({
        value: this.windowOpacity,
        min: 20,
        max: 100,
        step: 5,
        style: SliderStyle.OutSet
      })
        .blockColor(this.getPrimary())
        .selectedColor(this.getPrimary())
        .trackColor(this.getBorder())
        .blockSize(20)
        .trackThickness(6)
        .onChange((v: number) => this.onOpacityChanged(v));
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCardBg())
    .borderRadius(18)
    .border({ width: 1, color: this.getBorder() });
  }

  // === 主操作按钮 ===
  @Builder
  buildActionButton() {
    if (this.isFloatingShown) {
      Button() {
        Row({ space: 8 }) {
          Text('👁')
            .fontSize(18);
          Text('隐藏悬浮窗')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF');
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#F87171')
      .borderRadius(28)
      .shadow({ radius: 12, color: 'rgba(248,113,113,0.3)', offsetX: 0, offsetY: 4 })
      .margin({ top: 8 })
      .onClick(() => this.hideFloatingWindow());
    } else {
      Button() {
        Row({ space: 8 }) {
          Text('🚀')
            .fontSize(18);
          Text('显示悬浮窗')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF');
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor(this.getPrimary())
      .borderRadius(28)
      .shadow({ radius: 12, color: this.getTheme().colors.primary + '4D', offsetX: 0, offsetY: 4 })
      .margin({ top: 8 })
      .onClick(() => this.showFloatingWindow());
    }
  }

  // === 使用提示 ===
  @Builder
  buildTips() {
    Column({ space: 8 }) {
      Text('💡 使用小贴士')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTextSecondary())
        .width('100%')
        .margin({ top: 8, bottom: 4 });

      this.buildTipRow('长按悬浮窗可打开设置菜单');
      this.buildTipRow('单击可启动/暂停倒计时、秒表、番茄钟');
      this.buildTipRow('拖动悬浮窗可自由改变位置');
      this.buildTipRow('桌面长按空白处可添加时钟小组件');
    }
    .width('100%')
    .margin({ top: 8 });
  }

  @Builder
  buildTipRow(text: string) {
    Row({ space: 8 }) {
      Circle()
        .width(4)
        .height(4)
        .fill(this.getPrimary());

      Text(text)
        .fontSize(12)
        .fontColor(this.getTextSecondary());
    }
    .width('100%')
    .alignItems(VerticalAlign.Center);
  }

  // === 通用组件 ===
  @Builder
  buildSectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.getTextPrimary())
      .width('100%');
  }

  @Builder
  buildListRow(icon: string, title: string, value: boolean, showToggle: boolean, onToggle?: () => void, subText?: string) {
    Row() {
      Text(icon)
        .fontSize(18)
        .margin({ right: 12 });

      Text(title)
        .fontSize(15)
        .fontColor(this.getTextPrimary())
        .layoutWeight(1);

      if (subText !== undefined) {
        Text(subText)
          .fontSize(12)
          .fontColor(this.getTextSecondary());
      }

      if (showToggle) {
        Toggle({ type: ToggleType.Switch, isOn: value })
          .selectedColor(this.getPrimary())
          .switchPointColor('#FFFFFF')
          .onChange(() => {
            if (onToggle) onToggle();
          });
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 });
  }

  @Builder
  buildDivider() {
    Divider()
      .strokeWidth(0.5)
      .color(this.getDivider())
      .margin({ left: 40 });
  }
}
