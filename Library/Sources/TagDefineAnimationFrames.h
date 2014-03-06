//
//  TagDefineAnimationFrames.h
//  GAFPlayer
//
//  Created by timur.losev on 3/4/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__TagDefineAnimationFrames__
#define __GAFPlayer__TagDefineAnimationFrames__

#include "DefinitionTagBase.h"

@class GAFSubobjectState;

class TagDefineAnimationFrames : public DefinitionTagBase
{
private:
    GAFSubobjectState* extractState(GAFStream* in);
    
public:
    
    virtual void read(GAFStream*, GAFAsset*);
    
};

#endif /* defined(__GAFPlayer__TagDefineAnimationFrames__) */
