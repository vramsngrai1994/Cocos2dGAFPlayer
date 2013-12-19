////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFSpriteWithAlpha.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFSprite.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFSpriteWithAlpha : GAFSprite
{
@private
    GLfloat _colorTransform[8]; // 0-3 mults, 4-7 offsets
    GLuint  _colorTrasformLocation;
}

@property (nonatomic, assign) CGSize blurRadius;

- (void)setColorTransformMult:(const GLfloat *)mults offsets:(const GLfloat *)offsets;
- (void)setColorTransform:(const GLfloat *)colorTransform;
- (GLfloat *)getColorTransform;

@end
