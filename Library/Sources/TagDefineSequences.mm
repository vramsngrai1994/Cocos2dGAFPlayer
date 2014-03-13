//
//  TagDefineSequences.cpp
//  GAFPlayer
//
//  Created by timur.losev on 3/6/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "TagDefineSequences.h"

#include "GAFStream.h"
#import "GAFAsset.h"
#import "GAFAnimationSequence.h"

void TagDefineSequences::read(GAFStream* in, GAFAsset* ctx)
{
    unsigned int count = in->readU32();
    
    for (unsigned int i = 0; i < count; ++i)
    {
        std::string ids;
        in->readString(&ids);
        int start = in->readU16();
        int end = in->readU16();
        
        NSString* name = [NSString stringWithCString:ids.c_str() encoding:[NSString defaultCStringEncoding]];
        
        GAFAnimationSequence* seq = [[GAFAnimationSequence alloc] initWithName:name frameStart:start frameEnd:end];
        
        [ctx.animationSequences setObject:seq forKey:name];
    }
}
