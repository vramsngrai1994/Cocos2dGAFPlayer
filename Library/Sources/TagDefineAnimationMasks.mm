//
//  TagDefineAnimationMasks.cpp
//  GAFPlayer
//
//  Created by timur.losev on 3/4/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "TagDefineAnimationMasks.h"

#include "GAFStream.h"
#import "GAFAsset.h"

void TagDefineAnimationMasks::read(GAFStream* in, GAFAsset* ctx)
{
    unsigned int count = in->readU32();
    
    for (unsigned int i = 0; i < count; ++i)
    {
        NSNumber* objectId = [NSNumber numberWithUnsignedInteger:in->readU32()];
        NSNumber* elementAtlasIdRef = [NSNumber numberWithUnsignedInteger:in->readU32()];
        
        [ctx.animationMasks setObject:elementAtlasIdRef forKey:objectId];
    }
}