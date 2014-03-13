//
//  GAFLoader.cpp
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "GAFLoader.h"
#include "GAFAsset.h"
#include "DefinitionTagBase.h"
#include "GAFHeader.h"
#include "GAFStream.h"
#include "GAFFile.h"

#include "PrimitiveDeserializer.h"

#include "TagDefineAtlas.h"
#include "TagDefineAnimationMasks.h"
#include "TagDefineAnimationObjects.h"
#include "TagDefineAnimationFrames.h"
#include "TagDefineNamedParts.h"
#include "TagDefineSequences.h"


std::string Tags::toString(Enum e)
{
    switch (e)
    {
        case Tags::TagEnd:
            return "TagEnd";
            break;
        case Tags::TagDefineAtlas:
            return "TagDefineAtlas";
            break;
        case Tags::TagDefineAnimationMasks:
            return "TagDefineAnimationMasks";
            break;
        case Tags::TagDefineAnimationObjects:
            return "TagDefineAnimationObjects";
            break;
        case Tags::TagDefineAnimationFrames:
            return "TagDefineAnimationFrames";
            break;
        case Tags::TagDefineNamedParts:
            return "TagDefineNamedParts";
            break;
        case Tags::TagDefineSequences:
            return "TagDefineSequences";
            break;
        default:
            return "";
            assert(false);
    }
}

void GAFLoader::_readHeaderEnd(GAFHeader& header)
{
    header.framesCount = m_stream->readU16();
    PrimitiveDeserializer::deserialize(m_stream, &header.frameSize);
    PrimitiveDeserializer::deserialize(m_stream, &header.pivot);
}

void GAFLoader::_registerTagLoaders()
{
    m_tagLoaders[Tags::TagDefineAtlas] = new TagDefineAtlas();
    m_tagLoaders[Tags::TagDefineAnimationMasks] = new TagDefineAnimationMasks();
    m_tagLoaders[Tags::TagDefineAnimationObjects] = new TagDefineAnimationObjects();
    m_tagLoaders[Tags::TagDefineAnimationFrames] = new TagDefineAnimationFrames();
    m_tagLoaders[Tags::TagDefineNamedParts] = new TagDefineNamedParts();
    m_tagLoaders[Tags::TagDefineNamedParts] = new TagDefineNamedParts();
    m_tagLoaders[Tags::TagDefineSequences] = new TagDefineSequences();
}

GAFLoader::GAFLoader():
m_stream(NULL)
{
    _registerTagLoaders();
}

GAFLoader::~GAFLoader()
{
    for (TagLoaders_t::iterator i = m_tagLoaders.begin(), e = m_tagLoaders.end(); i != e; ++i)
    {
        delete i->second;
    }
}

bool GAFLoader::_loadFile(GAFFile *file, GAFAsset* context)
{
    bool retval = true;
    
    m_stream = new GAFStream(file);
    
    GAFHeader& header = m_stream->getInput()->getHeader();
    
    _readHeaderEnd(header);
    
    while (!m_stream->isEndOfStream())
    {
        Tags::Enum tag = m_stream->openTag();
        
        TagLoaders_t::iterator it = m_tagLoaders.find(tag);
        
        if (it != m_tagLoaders.end())
        {
            it->second->read(m_stream, context);
        }
        else
        {
            // TODO: show warning
        }
        
        m_stream->closeTag();
    }
    
    delete m_stream;
    
    return retval;
}

bool GAFLoader::loadFile(NSData* fileData, GAFAsset* context)
{
    GAFFile* file = new GAFFile();
    
    bool retval = false;
    
    if (file->openWithData(fileData))
    {
        retval = _loadFile(file, context);
    }
    
    delete file;
    
    return retval;
}

bool GAFLoader::loadFile(NSString* fname, GAFAsset* context)
{
    GAFFile* file = new GAFFile();
    
    bool retval = false;
    
    if (file->open(fname, "rb"))
    {
        retval = _loadFile(file, context);
    }
    
    delete file;
    
    return retval;
}

bool GAFLoader::isFileLoaded() const
{
    return m_stream && m_stream->isEndOfStream();
}

GAFStream* GAFLoader::getStream() const
{
    return m_stream;
}

const GAFHeader& GAFLoader::getHeader() const
{
    return m_stream->getInput()->getHeader();
}
