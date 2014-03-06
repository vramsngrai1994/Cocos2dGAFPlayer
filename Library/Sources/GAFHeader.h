//
//  GAFHeader.h
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef GAFPlayer_GAFHeader_h
#define GAFPlayer_GAFHeader_h


class GAFHeader
{
public:
    
    enum Compression
    {
        __CompressionDefault = 0, // Internal
        CompressedNone = 0x00474146,
        CompressedZip = 0x00474143,
    };
    
public:
    Compression     compression;
    unsigned short  version;
    unsigned int    fileLenght;
    unsigned short  framesCount;
    CGRect          frameSize;
    CGPoint         pivot;
};

#endif
