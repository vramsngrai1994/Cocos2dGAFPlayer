//
//  GAFFile.h
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__GAFFile__
#define __GAFPlayer__GAFFile__

#include "GAFHeader.h"

#include <iostream>
#include <string>

class GAFFile
{
private:
    unsigned char*        m_data;
    unsigned int          m_dataPosition;
    unsigned long         m_dataLen;
    GAFHeader             m_header;
protected:
    void                 _readHeaderBegin(GAFHeader&);
    
public:
    GAFFile();
    ~GAFFile();
    
    unsigned char        read1Byte();
    unsigned short       read2Bytes();
    unsigned int         read4Bytes();
    unsigned long long   read8Bytes();
    float                readFloat();
    double               readDouble();
    
    bool                 isEOF() const;
    
    unsigned int         readString(std::string* dst); // function reads lenght prefixed string
    void                 readBytes(void* dst, unsigned int len);
    
    void                 close();
    
    // TODO: Provide error codes
    bool                 open(NSString* filename, const char* openMode);
    bool                 openWithData(NSData* data);
    bool                 isOpened() const;
    
    const GAFHeader&     getHeader() const;
    GAFHeader&           getHeader();
    
    unsigned int         getPosition() const;
    void                 rewind(unsigned int newPos);
};

#endif /* defined(__GAFPlayer__GAFFile__) */
