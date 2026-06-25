/**
 * 主题数据模型 - 遵循 HarmonyOS Design 设计规范
 * 包含 8 套精选主题，每套主题都有完整的色彩系统
 */

export interface ThemeColorToken {
  primary: string;
  primaryLight: string;
  primaryDark: string;
  onPrimary: string;
  bgPrimary: string;
  bgSecondary: string;
  bgElevated: string;
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;
  borderColor: string;
  dividerColor: string;
  shadowColor: string;
  success: string;
  warning: string;
  danger: string;
}

export interface ThemeStyle {
  name: string;
  label: string;
  isDark: boolean;
  bgColor: string;
  textColor: string;
  subTextColor: string;
  borderColor: string;
  shadowColor: string;
  primaryColor: string;
  colors: ThemeColorToken;
}

export class ThemeManager {
  static readonly THEMES: ThemeStyle[] = [
    {
      name: 'harmony_dark',
      label: '鸿蒙夜曲',
      isDark: true,
      bgColor: 'rgba(26, 26, 30, 0.92)',
      textColor: '#FFFFFF',
      subTextColor: 'rgba(255, 255, 255, 0.65)',
      borderColor: 'rgba(255, 255, 255, 0.08)',
      shadowColor: 'rgba(0, 0, 0, 0.6)',
      primaryColor: '#007DFF',
      colors: {
        primary: '#007DFF',
        primaryLight: '#409EFF',
        primaryDark: '#0062CC',
        onPrimary: '#FFFFFF',
        bgPrimary: '#1A1A1E',
        bgSecondary: '#22222A',
        bgElevated: '#2A2A32',
        textPrimary: '#FFFFFF',
        textSecondary: 'rgba(255,255,255,0.65)',
        textTertiary: 'rgba(255,255,255,0.35)',
        borderColor: 'rgba(255,255,255,0.08)',
        dividerColor: 'rgba(255,255,255,0.06)',
        shadowColor: 'rgba(0,0,0,0.6)',
        success: '#4ADE80',
        warning: '#FACC15',
        danger: '#F87171'
      }
    },
    {
      name: 'harmony_light',
      label: '晨曦微光',
      isDark: false,
      bgColor: 'rgba(255, 255, 255, 0.92)',
      textColor: '#1A1A1A',
      subTextColor: 'rgba(26, 26, 26, 0.6)',
      borderColor: 'rgba(0, 0, 0, 0.06)',
      shadowColor: 'rgba(0, 0, 0, 0.08)',
      primaryColor: '#007DFF',
      colors: {
        primary: '#007DFF',
        primaryLight: '#409EFF',
        primaryDark: '#0062CC',
        onPrimary: '#FFFFFF',
        bgPrimary: '#F5F5F5',
        bgSecondary: '#FFFFFF',
        bgElevated: '#FFFFFF',
        textPrimary: '#1A1A1A',
        textSecondary: 'rgba(26,26,26,0.6)',
        textTertiary: 'rgba(26,26,26,0.35)',
        borderColor: 'rgba(0,0,0,0.06)',
        dividerColor: 'rgba(0,0,0,0.04)',
        shadowColor: 'rgba(0,0,0,0.08)',
        success: '#22C55E',
        warning: '#EAB308',
        danger: '#EF4444'
      }
    },
    {
      name: 'ocean_deep',
      label: '深海低语',
      isDark: true,
      bgColor: 'rgba(5, 20, 40, 0.9)',
      textColor: '#E0F2FE',
      subTextColor: 'rgba(224, 242, 254, 0.6)',
      borderColor: 'rgba(56, 189, 248, 0.15)',
      shadowColor: 'rgba(0, 30, 60, 0.6)',
      primaryColor: '#0EA5E9',
      colors: {
        primary: '#0EA5E9',
        primaryLight: '#38BDF8',
        primaryDark: '#0284C7',
        onPrimary: '#FFFFFF',
        bgPrimary: '#051428',
        bgSecondary: '#0A1E3C',
        bgElevated: '#0F2850',
        textPrimary: '#E0F2FE',
        textSecondary: 'rgba(224,242,254,0.6)',
        textTertiary: 'rgba(224,242,254,0.35)',
        borderColor: 'rgba(56,189,248,0.15)',
        dividerColor: 'rgba(56,189,248,0.08)',
        shadowColor: 'rgba(0,30,60,0.6)',
        success: '#34D399',
        warning: '#FBBF24',
        danger: '#F87171'
      }
    },
    {
      name: 'forest_green',
      label: '林间晨光',
      isDark: true,
      bgColor: 'rgba(8, 30, 22, 0.9)',
      textColor: '#D1FAE5',
      subTextColor: 'rgba(209, 250, 229, 0.6)',
      borderColor: 'rgba(52, 211, 153, 0.15)',
      shadowColor: 'rgba(0, 30, 20, 0.6)',
      primaryColor: '#10B981',
      colors: {
        primary: '#10B981',
        primaryLight: '#34D399',
        primaryDark: '#059669',
        onPrimary: '#FFFFFF',
        bgPrimary: '#081E16',
        bgSecondary: '#0D2A20',
        bgElevated: '#13382B',
        textPrimary: '#D1FAE5',
        textSecondary: 'rgba(209,250,229,0.6)',
        textTertiary: 'rgba(209,250,229,0.35)',
        borderColor: 'rgba(52,211,153,0.15)',
        dividerColor: 'rgba(52,211,153,0.08)',
        shadowColor: 'rgba(0,30,20,0.6)',
        success: '#34D399',
        warning: '#FBBF24',
        danger: '#F87171'
      }
    },
    {
      name: 'sunset_warm',
      label: '暮光暖韵',
      isDark: true,
      bgColor: 'rgba(35, 15, 15, 0.9)',
      textColor: '#FEE2E2',
      subTextColor: 'rgba(254, 226, 226, 0.65)',
      borderColor: 'rgba(248, 113, 113, 0.15)',
      shadowColor: 'rgba(40, 10, 10, 0.6)',
      primaryColor: '#F97316',
      colors: {
        primary: '#F97316',
        primaryLight: '#FB923C',
        primaryDark: '#EA580C',
        onPrimary: '#FFFFFF',
        bgPrimary: '#230F0F',
        bgSecondary: '#2E1616',
        bgElevated: '#3A1D1D',
        textPrimary: '#FEE2E2',
        textSecondary: 'rgba(254,226,226,0.65)',
        textTertiary: 'rgba(254,226,226,0.35)',
        borderColor: 'rgba(248,113,113,0.15)',
        dividerColor: 'rgba(248,113,113,0.08)',
        shadowColor: 'rgba(40,10,10,0.6)',
        success: '#4ADE80',
        warning: '#FACC15',
        danger: '#F87171'
      }
    },
    {
      name: 'purple_dream',
      label: '紫雾梦境',
      isDark: true,
      bgColor: 'rgba(25, 10, 40, 0.9)',
      textColor: '#EDE9FE',
      subTextColor: 'rgba(237, 233, 254, 0.65)',
      borderColor: 'rgba(167, 139, 250, 0.2)',
      shadowColor: 'rgba(20, 5, 40, 0.6)',
      primaryColor: '#8B5CF6',
      colors: {
        primary: '#8B5CF6',
        primaryLight: '#A78BFA',
        primaryDark: '#7C3AED',
        onPrimary: '#FFFFFF',
        bgPrimary: '#190A28',
        bgSecondary: '#231136',
        bgElevated: '#2E1748',
        textPrimary: '#EDE9FE',
        textSecondary: 'rgba(237,233,254,0.65)',
        textTertiary: 'rgba(237,233,254,0.35)',
        borderColor: 'rgba(167,139,250,0.2)',
        dividerColor: 'rgba(167,139,250,0.08)',
        shadowColor: 'rgba(20,5,40,0.6)',
        success: '#4ADE80',
        warning: '#FACC15',
        danger: '#F87171'
      }
    },
    {
      name: 'mono_elegant',
      label: '极致黑白',
      isDark: true,
      bgColor: 'rgba(12, 12, 14, 0.95)',
      textColor: '#F5F5F5',
      subTextColor: 'rgba(245, 245, 245, 0.5)',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      shadowColor: 'rgba(0, 0, 0, 0.8)',
      primaryColor: '#FFFFFF',
      colors: {
        primary: '#FFFFFF',
        primaryLight: '#D4D4D4',
        primaryDark: '#A3A3A3',
        onPrimary: '#000000',
        bgPrimary: '#0C0C0E',
        bgSecondary: '#17171A',
        bgElevated: '#222226',
        textPrimary: '#F5F5F5',
        textSecondary: 'rgba(245,245,245,0.5)',
        textTertiary: 'rgba(245,245,245,0.3)',
        borderColor: 'rgba(255,255,255,0.1)',
        dividerColor: 'rgba(255,255,255,0.05)',
        shadowColor: 'rgba(0,0,0,0.8)',
        success: '#FFFFFF',
        warning: '#D4D4D4',
        danger: '#F5F5F5'
      }
    },
    {
      name: 'rose_gold',
      label: '玫瑰金调',
      isDark: false,
      bgColor: 'rgba(255, 248, 245, 0.95)',
      textColor: '#5C3D2E',
      subTextColor: 'rgba(92, 61, 46, 0.55)',
      borderColor: 'rgba(205, 127, 90, 0.15)',
      shadowColor: 'rgba(92, 30, 10, 0.1)',
      primaryColor: '#CD7F5A',
      colors: {
        primary: '#CD7F5A',
        primaryLight: '#DDA487',
        primaryDark: '#B8663D',
        onPrimary: '#FFFFFF',
        bgPrimary: '#FFF8F5',
        bgSecondary: '#FFFEFD',
        bgElevated: '#FFFFFF',
        textPrimary: '#5C3D2E',
        textSecondary: 'rgba(92,61,46,0.55)',
        textTertiary: 'rgba(92,61,46,0.3)',
        borderColor: 'rgba(205,127,90,0.15)',
        dividerColor: 'rgba(205,127,90,0.08)',
        shadowColor: 'rgba(92,30,10,0.1)',
        success: '#86C47B',
        warning: '#E5B755',
        danger: '#E57373'
      }
    }
  ];

  static getTheme(name: string): ThemeStyle {
    const theme = ThemeManager.THEMES.find((t) => t.name === name);
    return theme ?? ThemeManager.THEMES[0];
  }

  static getIndex(name: string): number {
    return ThemeManager.THEMES.findIndex((t) => t.name === name);
  }
}
