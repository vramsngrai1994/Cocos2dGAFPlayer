//
//  TagDefineNamedParts.cpp
//  GAFPlayer
//
//  Created by timur.losev on 3/6/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "TagDefineNamedParts.h"

#import "GAFAsset.h"
#include "GAFStream.h"


void TagDefineNamedParts::read(GAFStream* in, GAFAsset* ctx)
{
    unsigned int count = in->readU32();
    
    for (unsigned int i = 0; i < count; ++i)
    {
        unsigned int objectIdRef = in->readU32();
        std::string name;
        in->readString(&name);
        
        NSString* nsName = [NSString stringWithCString:name.c_str()
                                              encoding:[NSString defaultCStringEncoding]];
        
        [ctx.namedParts setObject:nsName forKey:[NSNumber numberWithUnsignedInteger:objectIdRef]];
    }
}
