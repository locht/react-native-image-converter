//  RNImageConverter.h
#ifndef RNImageConverter_h
#define RNImageConverter_h
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RNImageConverter : NSObject <RCTBridgeModule>

@end

#endif /* RNImageConverter_h */
