//
//  TagDefineSequences.h
//  GAFPlayer
//
//  Created by timur.losev on 3/6/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__TagDefineSequences__
#define __GAFPlayer__TagDefineSequences__

#include "DefinitionTagBase.h"

class TagDefineSequences : public DefinitionTagBase
{
public:
    
    virtual void read(GAFStream*, GAFAsset*);
    
};

#endif /* defined(__GAFPlayer__TagDefineSequences__) */
