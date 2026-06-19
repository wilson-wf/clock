export interface ThemeStyle {
  name: string;
  label: string;
  bgColor: string;
  textColor: string;
  subTextColor: string;
  borderColor: string;
  shadowColor: string;
}

export class ThemeManager {
  static readonly THEMES: ThemeStyle[] = [
    {
      name: 'dark',
      label: '经典深色',
      bgColor: 'rgba(0, 0, 0, 0.75)',
      textColor: '#FFFFFF',
      subTextColor: 'rgba(255, 255, 255, 0.75)',
      borderColor: 'rgba(255, 255, 255, 0.15)',
      shadowColor: 'rgba(0, 0, 0, 0.5)'
    },
    {
      name: 'light',
      label: '清爽浅色',
      bgColor: 'rgba(255, 255, 255, 0.9)',
      textColor: '#1F1F1F',
      subTextColor: 'rgba(0, 0, 0, 0.6)',
      borderColor: 'rgba(0, 0, 0, 0.08)',
      shadowColor: 'rgba(0, 0, 0, 0.15)'
    },
    {
      name: 'ocean',
      label: '海洋蓝',
      bgColor: 'rgba(10, 61, 98, 0.85)',
      textColor: '#E0F4FF',
      subTextColor: 'rgba(224, 244, 255, 0.7)',
      borderColor: 'rgba(120, 200, 255, 0.3)',
      shadowColor: 'rgba(10, 61, 98, 0.4)'
    },
    {
      name: 'sunset',
      label: '日落橙',
      bgColor: 'rgba(90, 30, 20, 0.85)',
      textColor: '#FFE8D6',
      subTextColor: 'rgba(255, 232, 214, 0.7)',
      borderColor: 'rgba(255, 150, 100, 0.3)',
      shadowColor: 'rgba(90, 30, 20, 0.4)'
    },
    {
      name: 'forest',
      label: '森林绿',
      bgColor: 'rgba(22, 60, 40, 0.85)',
      textColor: '#E8F5E9',
      subTextColor: 'rgba(232, 245, 233, 0.7)',
      borderColor: 'rgba(150, 220, 170, 0.3)',
      shadowColor: 'rgba(22, 60, 40, 0.4)'
    },
    {
      name: 'mono',
      label: '极简黑白',
      bgColor: 'rgba(30, 30, 30, 0.9)',
      textColor: '#F5F5F5',
      subTextColor: 'rgba(245, 245, 245, 0.6)',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      shadowColor: 'rgba(0, 0, 0, 0.5)'
    }
  ];

  static getTheme(name: string): ThemeStyle {
    const theme = ThemeManager.THEMES.find((t) => t.name === name);
    return theme ?? ThemeManager.THEMES[0];
  }
}
