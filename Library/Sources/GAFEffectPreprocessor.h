//
//  GAFEffectPreprocessor.h
//  GAFPlayer
//
//  Created by Sergey Sergeev on 12/13/13.
//  Copyright (c) 2013 CatalystApps. All rights reserved.
//

#import "cocos2d.h"

@interface GAFPreprocessedTexture : NSObject

@property(nonatomic, strong) CCTexture2D* texture;
@property(nonatomic, assign) CGRect frame;
@property(nonatomic, assign) CGFloat scale;

@end


@interface GAFEffectPreprocessor : NSObject

+ (GAFEffectPreprocessor *)sharedInstance;
- (GAFPreprocessedTexture*)gaussianBlurredTextureFromTexture:(CCTexture2D *)sourceTexture
                                                       frame:(CGRect)sourceFrame
                                                    blurredSize:(CGSize)blurredSize;

@end
