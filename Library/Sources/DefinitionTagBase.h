//
//  DefinitionTagBase.h
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef GAFPlayer_DefinitionTagBase_h
#define GAFPlayer_DefinitionTagBase_h

class GAFStream;
@class GAFAsset;

class DefinitionTagBase
{
public:
    virtual ~DefinitionTagBase() {};
    
    virtual void read(GAFStream*, GAFAsset*) = 0;
};


#endif
