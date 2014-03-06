//
//  PrimiriveDeserializer.h
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#ifndef __GAFPlayer__PrimiriveDeserializer__
#define __GAFPlayer__PrimiriveDeserializer__


#import <ccTypes.h>

class GAFStream;

class PrimitiveDeserializer
{
public:
    static void deserialize(GAFStream* in, CGPoint* out);
    static void deserialize(GAFStream* in, CGRect* out);
    static void deserialize(GAFStream* in, CGAffineTransform* out);
    static void deserialize(GAFStream* in, CGSize* out);
    static void deserialize(GAFStream* in, ccColor4B* out);
};

#endif /* defined(__GAFPlayer__PrimiriveDeserializer__) */
