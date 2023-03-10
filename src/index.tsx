import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-image-converter' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const RNImageConverter = NativeModules.RNImageConverter
  ? NativeModules.RNImageConverter
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

class IImageConverter {
  static convert(param) {
      if (param.hasOwnProperty('grayscale')) {
          param.grayscale = param.grayscale.toString().toLowerCase();
      } else {
          param.grayscale = "false";
      }
      if (param.hasOwnProperty('base64')) {
          param.base64 = param.base64.toString().toLowerCase();
      } else {
          param.base64 = "false";
      }
      if (param.hasOwnProperty('resizeRatio')) {
          param.resizeRatio = IImageConverter.checkToInputValue(param.resizeRatio);
      } else {
          param.resizeRatio = "1.0";
      }
      if (param.hasOwnProperty('imageQuality')) {
          param.imageQuality = IImageConverter.checkToInputValue(param.imageQuality);
      } else {
          param.imageQuality = "1.0";
      }

      try {
          if (Platform.OS === "ios") {
              return RNImageConverter.imageConvert(param).then(result => (result));
          } else if (Platform.OS === "android") {
              return new Promise((resolve) => {
                  RNImageConverter.imageConvert(param, resolve);
                });
          } else {
              return {
                  success: false,
                  errorMsg: "not yet supported.("+Platform.OS+")"
              }
          }
      } catch(error) {
          return {
              success: false,
              errorMsg: "check your native("+Platform.OS+") module setting."
          }
      }
  }

  static checkToInputValue(inputValue) {
      try {
          var checkDataToString = inputValue.toString();
          var checkData = parseFloat(checkDataToString);
          if (checkData <= 0 || checkData > 1.0) {
              return "1.0";
          } else {
              return checkDataToString;
          }
      } catch(error) {
          return "1.0";
      }
  }
}

export default IImageConverter;
