//
//  TagDefineAtlas.cpp
//  GAFPlayer
//
//  Created by timur.losev on 3/6/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "TagDefineAtlas.h"

#include "GAFStream.h"
#import "GAFAsset.h"

#import "GAFTextureAtlas.h"
#import "GAFTextureAtlasElement.h"
#include "PrimitiveDeserializer.h"


void TagDefineAtlas::read(GAFStream* in, GAFAsset* ctx)
{
    GAFTextureAtlas* txAtlas = [GAFTextureAtlas new];
    txAtlas.atlasInfos = [NSMutableArray array];
    txAtlas.elements = [NSMutableDictionary dictionary];
    
    txAtlas.scale = in->readFloat();
    
    unsigned char atlasesCount = in->readUByte();
    
    for (unsigned char i = 0; i < atlasesCount; ++i)
    {
        AtlasInfo* ai = [[AtlasInfo alloc] init];
        ai.sources = [NSMutableArray array];
        
        ai.idx = in->readU32();
        
        unsigned char sources = in->readUByte();
        
        for (unsigned char j = 0; j < sources; ++j)
        {
            Source* aiSource = [Source new];
            
            std::string str;
            
            in->readString(&str);
            
            aiSource.source = [NSString stringWithCString:str.c_str() encoding:[NSString defaultCStringEncoding]];
            
            aiSource.csf = in->readFloat();
            
            [ai.sources addObject:aiSource];
        }
        
        [txAtlas.atlasInfos addObject:ai];
    }
    
    unsigned int elementsCount = in->readU32();
    
    for (unsigned int i = 0; i < elementsCount; ++i)
    {
        GAFTextureAtlasElement* element = [GAFTextureAtlasElement new];
        
        CGPoint pivotPoint;
        PrimitiveDeserializer::deserialize(in, &pivotPoint);
        
        element.pivotPoint = pivotPoint;
        
        CGPoint origin;
        
        PrimitiveDeserializer::deserialize(in, &origin);
        element.scale = in->readFloat();
        
        // TODO: Optimize this to read CCRect
        float width = in->readFloat();
        float height = in->readFloat();
        
        unsigned int atlasId = in->readU32();
        
        if (atlasId > 0)
        {
            atlasId--;
        }
        
        element.atlasIdx = [NSNumber numberWithUnsignedInteger: atlasId];
        
        element.elementAtlasIdx = [NSNumber numberWithUnsignedInteger:in->readU32()];
        
        
        element.bounds = CGRectMake(origin.x, origin.y, width, height);
        
        [txAtlas.elements setObject:element forKey:element.elementAtlasIdx];
    }
    
    [ctx.textureAtlases addObject:txAtlas];
}
