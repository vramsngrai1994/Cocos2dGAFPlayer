//
//  TagDefineStage.h
//  GAFPlayer
//
//  Created by timur.losev on 3/4/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__TagDefineStage__
#define __GAFPlayer__TagDefineStage__

#include "DefinitionTagBase.h"

class TagDefineStage : public DefinitionTagBase
{
public:
    virtual void read(GAFStream*, GAFAsset*);
};

#endif /* defined(__GAFPlayer__TagDefineStage__) */
