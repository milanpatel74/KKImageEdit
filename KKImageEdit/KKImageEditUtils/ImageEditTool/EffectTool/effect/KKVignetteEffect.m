//
//  HueEffect.m
//
//  Created by finger on 2015/10/23.
//  Copyright (c) 2015年 finger. All rights reserved.
//

#import "KKVignetteEffect.h"

@interface KKVignetteEffect()
{
}

@end

@implementation KKVignetteEffect

- (id)initWithSuperView:(UIView*)superview
{
    self = [super init];
    
    if(self){
        
    }
    
    return self ;
}

- (UIImage*)applyEffect:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIVignetteEffect" keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    
    CGFloat R = MIN(image.size.width, image.size.height)*image.scale/2;
    CIVector *vct = [[CIVector alloc] initWithX:image.size.width*image.scale/2 Y:image.size.height*image.scale/2];
    [filter setValue:vct forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
    [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end
