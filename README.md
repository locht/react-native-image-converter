# react-native-image-converter

A React-native module it can modify an image by simply.

### supported features.

-   resize
-   quality
-   grayscale
-   base64 encoding

### latest version

-   0.4.1

## install

-   React Native >= 0.60

```
yarn add https://github.com/locht/react-native-image-converter.git
cd ios && pod install
```

-   React Native <= 0.59

```
yarn add react-native-image-converter
react-native link react-native-image-converter
```

## usage

```javascript
import IImageConverter from 'react-native-image-converter'
...
const param = {
        path: uri,
        grayscale: false, // or true
        base64: false, // or true
        resizeRatio: 0.8, // 1.0 is origin value
        imageQuality: 0.7 // 1.0 is max quality value
      }

const { success, errorMsg, imageURI, base64String } = await IImageConverter.convert(param)
```

## request param

#### path - required value

-   type : string
-   description : The absolute path of the local file. (URI)

#### grayscale - optional value (default value is false)

-   type : boolean
-   description : If you want to make to grayscale, set true.

#### base64 - optional value (default value is false)

-   type : boolean
-   description : If you want to get image data by base64 encoding, set true.

#### resizeRatio - optional value (default value is 1.0)

-   type : float
-   description : Image resize ratio, between 0.1 to 1.0.

#### imageQuality - optional value (default value is 1.0)

-   type : float
-   description : Image quality, between 0.1 to 1.0.

## response value

#### success

-   type : boolean
-   description : success(true) or failure(false).

#### errorMsg

-   type : string
-   description : the message of errors.

#### imageURI

-   type : string
-   description : The absolute path of the edited file. (URI)

#### base64String

-   type : string
-   description : base64 encoded text data.

## setting the module to the project.

### android
-   Insert the line of dependencies block in `android/app/build.gradle`

    ```
    implementation 'org.apache.commons:commons-lang3:3.6'
    ```
