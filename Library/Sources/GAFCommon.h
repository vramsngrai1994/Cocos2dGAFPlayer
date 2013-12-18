//
//  NSObject_GAFCommon.h
//  GAFPlayer
//
//  Created by Sergey Sergeev on 12/17/13.
//  Copyright (c) 2013 CatalystApps. All rights reserved.
//

#define __ENABLE_EFFECT_PREPROCESSING_CACHING__ 1


static inline bool GAF_CGRectEqualToRect(CGRect rect1, CGRect rect2, CGFloat noise)
{
    return fabsf(rect1.origin.x - rect2.origin.x) < noise &&
    fabsf(rect1.origin.y - rect2.origin.y) < noise &&
    fabsf(rect1.size.width - rect2.size.width) < noise &&
    fabsf(rect1.size.height - rect2.size.height) < noise;
};

static inline bool GAF_CGSizeEqualToSize(CGSize size1, CGSize size2, CGFloat noise)
{
    return fabsf(size1.width - size2.width) < noise &&
    fabsf(size1.height - size2.height) < noise;
};

static inline CGAffineTransform GAF_CGAffineTransformCocosFormatFromFlashFormat (CGAffineTransform aTransform)
{
    CGAffineTransform transform = aTransform;
    transform.b  = - transform.b;
    transform.c  = - transform.c;
    transform.ty = - transform.ty;
    return transform;
};