//
//  GAFLoader.h
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__GAFLoader__
#define __GAFPlayer__GAFLoader__

#include <iostream>
#include <map>
#include <string>
#include "TagDefines.h"

@class GAFAsset;

class GAFStream;
class DefinitionTagBase;
class GAFHeader;
class GAFFile;

class GAFLoader
{
private:
    GAFStream*           m_stream;
    
    void                 _readHeaderEnd(GAFHeader&);
    void                 _registerTagLoaders();
    bool                 _loadFile(GAFFile* file, GAFAsset* context);
    
    typedef std::map<Tags::Enum, DefinitionTagBase*> TagLoaders_t;
    
    TagLoaders_t         m_tagLoaders;
    
public:
    GAFLoader();
    ~GAFLoader();
    
    bool                 loadFile(NSString* fname, GAFAsset* context);
    bool                 loadFile(NSData* fileData, GAFAsset* context);
    bool                 isFileLoaded() const;
    
    GAFStream*           getStream() const;
    
    const GAFHeader&     getHeader() const;
    
};

#endif /* defined(__GAFPlayer__GAFLoader__) */
