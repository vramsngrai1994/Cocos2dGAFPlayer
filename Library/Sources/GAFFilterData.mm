////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFFilterData.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFFilterData.h"
#import "GAFSpriteWithAlpha.h"
#import "GAFEffectPreprocessor.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

NSString * const kGAFBlurFilterName = @"Fblur";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GAFBlurFilterData

@synthesize blurSize;
@synthesize type;

- (id) init
{
    self = [super init];
    self.type = GFT_Blur;
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ %@, x:%f, y:%f }", kGAFBlurFilterName, blurSize.width, blurSize.height];
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    [object setBlurFiterData:self];
}

@end


@implementation GAFColorMatrixFilterData

@synthesize type;


- (id) init
{
    self = [super init];
    self.type = GFT_ColorMatrix;

    
    return self;
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    [object setColorMatrixFilterData:self];
}

@end


@implementation GAFGlowFilterData

@synthesize type;
@synthesize color;
@synthesize blurSize;
@synthesize strength;
@synthesize innerGlow;
@synthesize knockout;

- (id) init
{
    self = [super init];
    self.type = GFT_Glow;
    
    self.innerGlow = NO;
    self.knockout = NO;
    
    return self;
}

- (void) apply:(GAFSpriteWithAlpha *)object
{
    [object setGlowFilterData:self];
}

@end



@implementation GAFDropShadowFilterData

@synthesize type;
@synthesize color;
@synthesize blurSize;
@synthesize angle;
@synthesize distance;
@synthesize strength;
@synthesize innerShadow;
@synthesize knockout;

- (id) init
{
    self = [super init];
    self.type = GFT_DropShadow;
    self.innerShadow = NO;
    self.knockout = NO;
    
    return self;
}

const int kShadowObjectTag = 0xFAD0;

- (void) apply:(GAFSpriteWithAlpha *)object
{
    GAFPreprocessedTexture* shadowObject = [[GAFEffectPreprocessor sharedInstance] dropShadowTextureFromTexture:object.texture frame:object.textureRect dsData:self];
    
    [GAFDropShadowFilterData reset:object];
    
    CCSprite* shadowSprite = [[CCSprite alloc] initWithTexture:shadowObject.texture rect:shadowObject.frame];
  
    [object addChild:shadowSprite z:-1];
    
    [shadowSprite setAnchorPoint:object.anchorPoint];
    
    const CGFloat angleRad = ((CGFloat)M_PI / (CGFloat)180) * self.angle;
    
    CGPoint pos = ccp(object.contentSize.width * object.anchorPoint.x, object.contentSize.height * object.anchorPoint.y);
    
    CGPoint offset = ccp(cos(angleRad) * self.distance, -sin(angleRad) * self.distance);
    
    pos.x += offset.x;
    pos.y += offset.y;
    
    CGSize shadowTextureSize = shadowSprite.contentSize;
    
    if (shadowObject.frame.size.height < shadowTextureSize.height)
    {
        offset.y -= shadowTextureSize.height - shadowObject.frame.size.height;
    }
    
    [shadowSprite setFlipY:YES];
    shadowSprite.tag = kShadowObjectTag;
    shadowSprite.position = pos;
}

+ (void) reset:(GAFSpriteWithAlpha *)object
{
    CCNode* prevShadowObject = [object getChildByTag:kShadowObjectTag];
    
    if (prevShadowObject)
    {
        [object removeChild:prevShadowObject cleanup:YES];
    }
}

@end