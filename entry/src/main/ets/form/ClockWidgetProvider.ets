/**
 * 桌面时钟小组件 (ArkTS Widget)
 * 提供 FormExtensionAbility，为系统桌面提供时钟小组件
 */
import { FormExtensionAbility, formBindingData, FormInfo, FormProvider, Want } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { TimeFormatter } from '../utils/TimeFormatter';

const DOMAIN: number = 0x0010;
const TAG: string = 'ClockWidgetProvider';
const PREFS_FILE = 'floating_clock_prefs';
const KEY_THEME = 'theme_name';

export default class ClockWidgetProvider extends FormExtensionAbility {
  onAddForm(want: Want): FormBindingData {
    hilog.info(DOMAIN, TAG, 'Widget onAddForm, formId: %{public}s', want.parameters?.['ohos.extra.param.key.form_identity'] as string);
    return this.createClockBindingData();
  }

  onUpdateForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'Widget onUpdateForm: %{public}s', formId);
  }

  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'Widget onRemoveForm: %{public}s', formId);
  }

  onCastToNormalForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'Widget onCastToNormalForm: %{public}s', formId);
  }

  onNotifyFormData(formId: string, message: string): void {
    hilog.info(DOMAIN, TAG, 'Widget onNotifyFormData: %{public}s, message: %{public}s', formId, message);
  }

  onShareFormData(formId: string): Record<string, string> {
    return { 'time': this.getCurrentTimeString() };
  }

  private createClockBindingData(): formBindingData.FormBindingData {
    const now = new Date();
    const result = TimeFormatter.formatClock(now);
    const dateStr = this.getDateString(now);

    const dataObj: Record<string, string | number> = {
      'time': result.time,
      'date': dateStr,
      'theme': 'dark'
    };

    return formBindingData.createFormBindingData(dataObj);
  }

  private getCurrentTimeString(): string {
    const now = new Date();
    const result = TimeFormatter.formatClock(now);
    return result.time;
  }

  private getDateString(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekday = weekdays[date.getDay()];
    return `${year}/${month}/${day} ${weekday}`;
  }
}
