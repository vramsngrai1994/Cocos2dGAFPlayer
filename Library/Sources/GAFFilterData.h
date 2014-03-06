////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFFilterData.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

- (void) apply:(GAFSpriteWithAlpha *)object;

@end


@interface GAFGlowFilterData : NSObject<GAFFilterData>

- (void) apply:(GAFSpriteWithAlpha *)object;

@end

@interface GAFDropShadowFilterData : NSObject<GAFFilterData>

- (void) apply:(GAFSpriteWithAlpha *)object;

@end