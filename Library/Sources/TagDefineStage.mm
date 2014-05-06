//
//  TagDefineAnimationObjects.cpp
//  GAFPlayer
//
//  Created by timur.losev on 3/4/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#import <ccTypes.h>
#import "TagDefineStage.h"
#import "PrimitiveDeserializer.h"
#import "GAFStream.h"
#import "GAFAsset.h"

void TagDefineStage::read(GAFStream* in, GAFAsset* ctx)
{
    ccColor4B color;
    
    NSUInteger fps = in->readU8();
    PrimitiveDeserializer::deserialize(in, &color);
    NSUInteger width = in->readU16();
    NSUInteger height = in->readU16();
    
    [ctx setSceneFps:fps];
    [ctx setSceneColor:color];
    [ctx setSceneHeight:height];
    [ctx setSceneWidth:width];
}
