//
//  PrimiriveDeserializer.cpp
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "PrimitiveDeserializer.h"

#include "GAFStream.h"


void PrimitiveDeserializer::deserialize(GAFStream* in, CGPoint* out)
{
    out->x = in->readFloat();
    out->y = in->readFloat();
}

void PrimitiveDeserializer::deserialize(GAFStream* in, CGRect* out)
{
    deserialize(in, &out->origin);
    deserialize(in, &out->size);
}

void PrimitiveDeserializer::deserialize(GAFStream* in, CGAffineTransform* out)
{
    in->readNBytesOfT(out, sizeof(CGAffineTransform));
}

void PrimitiveDeserializer::deserialize(GAFStream* in, CGSize* out)
{
    out->width = in->readFloat();
    out->height = in->readFloat();
}

void PrimitiveDeserializer::deserialize(GAFStream* in, ccColor4B* out)
{
    in->readNBytesOfT(out, 4);
}
