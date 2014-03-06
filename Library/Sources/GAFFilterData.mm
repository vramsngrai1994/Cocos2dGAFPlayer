////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFFilterData.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFFilterData.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * const kGAFBlurFilterName = @"Fblur";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GAFBlurFilterData

@synthesize blurSize;
@synthesize type;

- (id) init
{
    self = [self init];
    self.type = GFT_Blur;
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ %@, x:%f, y:%f }", kGAFBlurFilterName, blurSize.width, blurSize.height];
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    
}

@end


@implementation GAFColorMatrixFilterData

@synthesize type;

- (id) init
{
    self = [self init];
    self.type = GFT_ColorMatrix;
    
    return self;
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    
}

@end


@implementation GAFGlowFilterData

@synthesize type;

- (id) init
{
    self = [self init];
    self.type = GFT_Glow;
    
    return self;
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    
}

@end



@implementation GAFDropShadowFilterData

@synthesize type;

- (id) init
{
    self = [self init];
    self.type = GFT_DropShadow;
    
    return self;
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    
}


@end