//
//  GAFEffectPreprocessor.h
//  GAFPlayer
//
//  Created by Sergey Sergeev on 12/13/13.
//  Copyright (c) 2013 CatalystApps. All rights reserved.
//

#import "cocos2d.h"

@class GAFGlowFilterData;
@class GAFBlurFilterData;
@class GAFDropShadowFilterData;

@interface GAFPreprocessedTexture : NSObject

@property(nonatomic, strong) CCTexture2D* texture;
@property(nonatomic, assign) CGRect frame;
@property(nonatomic, assign) CGFloat scale;

@end


@interface GAFEffectPreprocessor : NSObject

+ (GAFEffectPreprocessor *)sharedInstance;
- (GAFPreprocessedTexture*) gaussianBlurredTextureFromTexture:(CCTexture2D *)sourceTexture
                                                       frame:(CGRect)sourceFrame
                                               blurFilterData:(GAFBlurFilterData*)blurFilterData;

- (GAFPreprocessedTexture*) glowTextureFromTexture:(CCTexture2D*) sourceTexture frame:(CGRect)sourceFrame  glowData:(GAFGlowFilterData*)glowFilterData;

- (GAFPreprocessedTexture*) dropShadowTextureFromTexture:(CCTexture2D*) sourceTexture frame:(CGRect)sourceFrame dsData:(GAFDropShadowFilterData*)dropShadowFilterData;

@end
