////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFFilterData.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <ccTypes.h>

extern NSString * const kGAFBlurFilterName;

@class GAFSpriteWithAlpha;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define GFT_DropShadow 0
#define GFT_Blur 1
#define GFT_Glow 2
#define GFT_ColorMatrix 6

@protocol GAFFilterData<NSObject>

@property (nonatomic, assign) NSUInteger type;

- (void) apply:(GAFSpriteWithAlpha*)object;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFBlurFilterData : NSObject<GAFFilterData>

@property (nonatomic, assign) CGSize blurSize;

- (void) apply:(GAFSpriteWithAlpha *)object;

@end


@interface GAFColorMatrixFilterData : NSObject<GAFFilterData>
{
@public
    float      matrix[16]; // Float matrix 4x4
    float      matrix2[4]; // Float matrix 2x2
}

- (void) apply:(GAFSpriteWithAlpha *)object;

@end


@interface GAFGlowFilterData : NSObject<GAFFilterData>

@property (nonatomic, assign) ccColor4F color;
@property (nonatomic, assign) CGSize blurSize;
@property (nonatomic, assign) CGFloat strength;
@property (nonatomic, assign) BOOL innerGlow;
@property (nonatomic, assign) BOOL knockout;

- (void) apply:(GAFSpriteWithAlpha *)object;

@end

@interface GAFDropShadowFilterData : NSObject<GAFFilterData>

@property (nonatomic, assign) ccColor4F color;
@property (nonatomic, assign) CGSize blurSize;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat strength;
@property (nonatomic, assign) BOOL innerShadow;
@property (nonatomic, assign) BOOL knockout;

- (void) apply:(GAFSpriteWithAlpha *)object;

+ (void) reset:(GAFSpriteWithAlpha *)object;

@end