//
//  PrimiriveDeserializer.cpp
//  GAFPlayer
//
//  Created by timur.losev on 2/26/14.
//  Copyright (c) 2014 CatalystApps. All rights reserved.
//

#include "PrimitiveDeserializer.h"

#include "GAFStream.h"

struct __CGAffineTransform
{
    float a, b, c, d;
    float tx, ty;
};

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
    __CGAffineTransform _out;
    in->readNBytesOfT(&_out, sizeof(__CGAffineTransform));
    
    out->a = _out.a;
    out->b = _out.b;
    out->c = _out.c;
    out->d = _out.d;
    out->tx = _out.tx;
    out->ty = _out.ty;
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
