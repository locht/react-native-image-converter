
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNImageConverterSpec.h"

@interface ImageConverter : NSObject <NativeImageConverterSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ImageConverter : NSObject <RCTBridgeModule>
#endif

@end
