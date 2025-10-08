const uiContext: UIContext | undefined = AppStorage.get('uiContext');

export class CommonUtils {
  showToast(message: string | Resource) {
    uiContext?.getPromptAction().showToast({ message, duration: 1000 });

  }
}

let commonUtils = new CommonUtils()

export default commonUtils as CommonUtils
