//
//  TagDefineAnimationFrames.cpp
//  GAFPlayer
//
//  Created by timur.losev on 3/4/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "TagDefineAnimationFrames.h"

#include "GAFStream.h"
#import  "GAFAsset.h"
#include "GAFFile.h"
#include "GAFHeader.h"

#include "PrimitiveDeserializer.h"

#import "GAFSubobjectState.h"
#import "GAFAnimationFrame.h"
#import "GAFFilterData.h"

void _translateColor(ccColor4F& out, const ccColor4B& in)
{
    out.b = in.r / 255.f;
    out.g = in.g / 255.f;
    out.r = in.b / 255.f;
    out.a = in.a / 255.f;
}

void TagDefineAnimationFrames::read(GAFStream* in, GAFAsset* ctx)
{
    unsigned int count = in->readU32();
    (void)count;
    
    NSMutableDictionary* currentStates = [NSMutableDictionary dictionary];
    
    //NSAssert(ctx.animationObjects.count > 0, @"Animation objects have to be filled.");
    
    NSEnumerator* enm = [ctx.animationObjects keyEnumerator];
    NSNumber* key;
    while (key = (NSNumber*)[enm nextObject])
    {
        GAFSubobjectState* state = [[GAFSubobjectState alloc] initEmpty:key];
        [currentStates setObject:state forKey:key];
    }
    
    const unsigned short totalFrameCount = in->getInput()->getHeader().framesCount;
    
    unsigned int frameNumber = in->readU32();
    
    for (unsigned int i = 0; i < totalFrameCount; ++i)
    {
        if ((frameNumber - 1) == i)
        {
            unsigned int numObjects = in->readU32();
            
            NSMutableArray* statesList = [NSMutableArray array]; // For GAFSubobjectState
            
            for (unsigned int j = 0; j < numObjects; ++j)
            {
                GAFSubobjectState* state = extractState(in);
                
                [statesList addObject: state];
            }
            
            for (NSUInteger j = 0; j < [statesList count]; ++j)
            {
                GAFSubobjectState* st = [statesList objectAtIndex:j];
                
                [currentStates setObject:st forKey:st.objectIdRef];
            }
            
            if (in->getPosition() < in->getTagExpectedPosition())
                frameNumber = in->readU32();
        }
        
        GAFAnimationFrame* frame = [GAFAnimationFrame new];
        
        enm = [currentStates keyEnumerator];
        
        while (key = (NSNumber*)[enm nextObject])
        {
            GAFSubobjectState* st = [currentStates objectForKey:key];
            [frame.objectsStates addObject:st];
        }
        
        [ctx.animationFrames addObject:frame];
    }
}

GAFSubobjectState* TagDefineAnimationFrames::extractState(GAFStream* in)
{
    GAFSubobjectState* state = [GAFSubobjectState new];
    
    float ctx[7];
    
    char hasColorTransform = in->readUByte();
    char hasMasks = in->readUByte();
    char hasEffect = in->readUByte();
    
    state.objectIdRef = [NSNumber numberWithUnsignedInteger:in->readU32()];
    state.zIndex = in->readS32();
    GLfloat* ctxmul = [state colorMults];
    ctxmul[GAFCTI_A] = in->readFloat();
    
    CGAffineTransform trans;
    PrimitiveDeserializer::deserialize(in, &trans);
    state.affineTransform = trans;
    
    if (hasColorTransform)
    {
        in->readNBytesOfT(ctx, sizeof(float)* 7);
        
        float* ctxOff = [state colorOffsets];
        float* ctxMul = [state colorMults];
        
        ctxOff[GAFCTI_A] = ctx[0];
        
        ctxMul[GAFCTI_R] = ctx[1];
        ctxOff[GAFCTI_R] = ctx[2];
        
        ctxMul[GAFCTI_G] = ctx[3];
        ctxOff[GAFCTI_G] = ctx[4];
        
        ctxMul[GAFCTI_B] = ctx[5];
        ctxOff[GAFCTI_B] = ctx[6];
    }
    else
    {
        [state ctxMakeIdentity];
    }
    
    if (hasEffect)
    {
        assert(false && "Unimplemented");
        unsigned char effectsCount = in->readUByte();
        
        for (unsigned int e = 0; e < effectsCount; ++e)
        {
            NSUInteger type = in->readU32();
            
            if (type == GFT_Blur)
            {
                CGSize p;
                PrimitiveDeserializer::deserialize(in, &p);
                GAFBlurFilterData* blutFilter = [[GAFBlurFilterData alloc] init];
                
            }
            else if (type == GFT_ColorMatrix)
            {
                
            }
            else if(type == GFT_Glow)
            {
                
            }
            else if(type == GFT_DropShadow)
            {
                
            }
        }
    }
    
    if (hasMasks)
    {
        state.maskObjectIdRef = [NSNumber numberWithUnsignedInteger:in->readU32()];
    }
    
    return state;
}