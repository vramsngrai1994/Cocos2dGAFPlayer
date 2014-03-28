////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFSpriteWithAlpha.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFSprite.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class GAFColorMatrixFilterData;
@class GAFGlowFilterData;
@class GAFBlurFilterData;

@interface GAFSpriteWithAlpha : GAFSprite
{
@private
    GLfloat _colorTransform[8]; // 0-3 mults, 4-7 offsets
    GLuint  _colorTrasformLocation;
    int     _colorMatrixLocation;
    int     _colorMatrixLocation2;
    
    GLfloat _colorMatrixIdentity1[16];
    GLfloat _colorMatrixIdentity2[4];
}

@property (nonatomic, assign) CGSize blurRadius;
@property (nonatomic, readonly) CGFloat postprocessedScale;
@property (nonatomic, readonly) CGRect  preprocessedFrame;
@property (nonatomic, readonly) CGRect  postprocessedFrame;

// When effect is applied texture is changed, next effect (e.g. change of blur radius) should be applied on the same
// initial texture, not modified one
@property (nonatomic, strong, readonly) CCTexture2D *initialTexture;
@property (nonatomic, readonly) CGRect      initialTextureRect;


@property (nonatomic, strong) GAFColorMatrixFilterData* colorMatrixFilterData;
@property (nonatomic, strong) GAFGlowFilterData*        glowFilterData;
@property (nonatomic, strong) GAFBlurFilterData*        blurFiterData;

- (void)setColorTransformMult:(const GLfloat *)mults offsets:(const GLfloat *)offsets;
- (void)setColorTransform:(const GLfloat *)colorTransform;
- (GLfloat *)getColorTransform;

@end
