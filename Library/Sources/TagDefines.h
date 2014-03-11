//
//  TagDefines.h
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef GAFPlayer_TagDefines_h
#define GAFPlayer_TagDefines_h


struct Tags
{
    enum Enum
    {
        TagEnd = 0,
        TagDefineAtlas = 1,
        TagDefineAnimationMasks = 2,
        TagDefineAnimationObjects = 3,
        TagDefineAnimationFrames = 4,
        TagDefineNamedParts = 5,
        TagDefineSequences = 6,
    };
    
    static std::string toString(Enum e);
};


#endif
