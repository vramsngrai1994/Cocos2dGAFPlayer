//
//  TagDefineAnimationObjects.h
//  GAFPlayer
//
//  Created by timur.losev on 3/4/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__TagDefineAnimationObjects__
#define __GAFPlayer__TagDefineAnimationObjects__

#include "DefinitionTagBase.h"

class TagDefineAnimationObjects : public DefinitionTagBase
{
public:
    virtual void read(GAFStream*, GAFAsset*);
};

#endif /* defined(__GAFPlayer__TagDefineAnimationObjects__) */
