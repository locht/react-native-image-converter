//  RNImageConverter.m
//  Created by IT on 08/02/2023.
#import <Foundation/Foundation.h>
#import "RNImageConverter.h"

@implementation RNImageConverter

static NSString *const ERROR_MESSAGE_EMPTY_URI_KEY = @"URI Path KEY('path') must not be null.";
static NSString *const ERROR_MESSAGE_EMPTY_URI_VALUE = @"URI Path Value must not be null.";

static NSString *const SUCCESS_KEY = @"success";
static NSString *const ERROR_MESSAGE_KEY = @"errorMsg";
static NSString *const IMAGE_URI_KEY = @"imageURI";
static NSString *const BASE64_KEY = @"base64";

static NSString *const PATH_KEY = @"path";
static NSString *const GRAYSCALE_KEY = @"grayscale";
static NSString *const RESIZE_RATIO_KEY = @"resizeRatio";
static NSString *const IMAGE_QUALITY_KEY = @"imageQuality";
static NSString *const BASE64_STRING_KEY = @"base64String";

static NSString *const SAVE_IMAGE_FILE_NAME_BY_OVERWRITE = @"modifiedImage.jpg";

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(imageConvert:(NSDictionary *) params
                  resolve:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject) {
    
    if ([params objectForKey:PATH_KEY] == nil) {
        return resolve(@{ SUCCESS_KEY: @NO, ERROR_MESSAGE_KEY: ERROR_MESSAGE_EMPTY_URI_KEY });
    }
    
    NSString *const uri = params[PATH_KEY];
    if ([uri length] == 0) {
        return resolve(@{ SUCCESS_KEY: @NO, ERROR_MESSAGE_KEY: ERROR_MESSAGE_EMPTY_URI_VALUE });
    }
    
    CGFloat resizeRatio = 1.0f;
    if ([params objectForKey:RESIZE_RATIO_KEY]) {
        NSString *resizeRatioString = params[RESIZE_RATIO_KEY];
        if ([resizeRatioString length] > 0) {
            resizeRatio = [resizeRatioString floatValue];
        }
    }
    
    CGFloat imageQuality = 1.0f;
    if ([params objectForKey:IMAGE_QUALITY_KEY]) {
        NSString *imageQualityString = params[IMAGE_QUALITY_KEY];
        if ([imageQualityString length] > 0) {
            imageQuality = [imageQualityString floatValue];
        }
    }
    
    BOOL imageToGrayscale = false;
    if ([params objectForKey:GRAYSCALE_KEY]) {
        NSString *imageToGrayscaleString = params[GRAYSCALE_KEY];
        imageToGrayscale = [imageToGrayscaleString boolValue];
    }
    
    NSString *const encodedURI = [uri stringByRemovingPercentEncoding];
    UIImage *const originImage = [self getNSImageByURI: encodedURI];
    UIImage *const resizedImage = [self modifyImage:originImage resizeRatio:resizeRatio];
    
    UIImage *grayscaleImage = nil;
    if (imageToGrayscale) {
        grayscaleImage = [self convertToGray:resizedImage];
    }
    
    if ([params objectForKey:BASE64_KEY] && [params[BASE64_KEY] boolValue]) {
        return resolve(@{
            SUCCESS_KEY: @YES,
            BASE64_STRING_KEY:[self getBase64FromImage:(grayscaleImage != nil ? grayscaleImage : resizedImage)]
        });
    } else {
        return resolve(@{
            SUCCESS_KEY: @YES,
            IMAGE_URI_KEY:
                [self saveImageToLocal:(grayscaleImage != nil ? grayscaleImage : resizedImage) fileName:SAVE_IMAGE_FILE_NAME_BY_OVERWRITE imageQuality:imageQuality]
        });
    }
}

- (UIImage *) getNSImageByURI:(NSString *) uri {
    NSURL *const url = [NSURL fileURLWithPath: uri];
    NSData *const data = [NSData dataWithContentsOfURL: url];
    return [UIImage imageWithData: data];
}

- (NSString *) saveImageToLocal:(UIImage *) image fileName:(NSString *) name imageQuality:(CGFloat) quality {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];

    NSData *data = UIImageJPEGRepresentation(image, quality);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:name];

    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    return fullPath;
}

- (UIImage *) modifyImage:(UIImage *) originImage resizeRatio:(CGFloat) sizeRatio {
    const int resizeWidth = originImage.size.width * sizeRatio;
    const int resizeHeight = originImage.size.height * sizeRatio;

    uint32_t *rgbImage = (uint32_t *) malloc(resizeWidth * resizeHeight * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, resizeWidth, resizeHeight, 8, (resizeWidth * 4), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
    CGContextSetShouldSmoothFonts (context, NO);
    CGContextSetAllowsFontSmoothing (context, NO);
    CGContextSetShouldAntialias(context, NO);
    
    CGContextDrawImage(context, CGRectMake(0, 0, resizeWidth, resizeHeight), [originImage CGImage]);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);

    return resultUIImage;
}

/**
    * https://gist.github.com/doskoi/1653064 this mehod, I Referenced here.
 */
- (UIImage *) convertToGray:(UIImage *) originImage {
    int const imageWith = originImage.size.width < originImage.size.height ? originImage.size.height : originImage.size.width;
    int const imageHeight = originImage.size.width > originImage.size.height ? originImage.size.height : originImage.size.width;
    
    CGRect imageRect = CGRectMake(0, 0, imageWith, imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, imageWith, imageHeight, 8, 0, colorSpace, kCGImageAlphaNone);

    CGContextDrawImage(context, imageRect, [originImage CGImage]);

    CGImageRef imageRef = CGBitmapContextCreateImage(context);

    //  Edit code camera rotate
    //  UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:0];
    //  End Edit
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);

    return newImage;
}

- (NSString *) getBase64FromImage:(UIImage *) originImage {
    NSData *imageData = UIImageJPEGRepresentation(originImage, 1.0);
    return [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

@end
  
