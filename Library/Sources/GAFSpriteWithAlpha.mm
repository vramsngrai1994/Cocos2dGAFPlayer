////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFSpriteWithAlpha.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFSpriteWithAlpha.h"
#import "GAFSprite_Protected.h"
#import "CCGLProgram+GAFExtensions.h"
#import "GAFEffectPreprocessor.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static NSString * const kAlphaFragmentShaderFilename = @"pcShader_PositionTextureAlpha_frag.fs";
static NSString * const kGAFSpriteWithAlphaShaderProgramCacheKey = @"kGAFSpriteWithAlphaShaderProgramCache";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFSpriteWithAlpha ()

// When effect is applied texture is changed, next effect (e.g. change of blur radius) should be applied on the same
// initial texture, not modified one
@property (nonatomic, strong) CCTexture2D *initialTexture;
@property (nonatomic, assign) CGRect      initialTextureRect;

@property (nonatomic, readwrite) CGFloat postprocessedScale;
@property (nonatomic, readwrite) CGRect  preprocessedFrame;
@property (nonatomic, readwrite) CGRect  postprocessedFrame;

- (CCGLProgram *)programForShader;
- (void)setBlendingFunc;

- (void)updateTextureWithEffects;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GAFSpriteWithAlpha

#pragma mark -
#pragma mark Properties

- (GLfloat *)getColorTransform
{
	return _colorTransform;
}

- (void)setColorTransformMult:(const GLfloat *) mults offsets:(const GLfloat *) offsets
{
	for (NSUInteger i = 0; i < 4; ++i)
	{
		_colorTransform[i]     = mults[i];
		_colorTransform[i + 4] = offsets[i];
	}
    [self setBlendingFunc];
}

- (void)setColorTransform:(const GLfloat *) colorTransform
{
	for (NSUInteger i = 0; i < 8; ++i)
	{
		_colorTransform[i] = colorTransform[i];
	}
	[self setBlendingFunc];
}

- (void)setBlurRadius:(CGSize)blurRadius
{
    if (!CGSizeEqualToSize(_blurRadius, blurRadius))
    {
        _blurRadius = blurRadius;
        [self updateTextureWithEffects];
    }
}

#pragma mark -
#pragma mark Initialization & Release

- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
    if ((self = [super initWithTexture:texture rect:rect rotated:rotated]))
    {
        _initialTexture = texture;
        _initialTextureRect = rect;
        _blurRadius = CGSizeZero;
        
        _postprocessedScale = 1.0f;
        _preprocessedFrame = _initialTextureRect;
        _postprocessedFrame = _initialTextureRect;
        
		for (int i = 0; i < 4; ++i)
		{
			_colorTransform[i]     = 1.0f;
			_colorTransform[i + 4] = 0;
		}
        [self setBlendingFunc];
        self.shaderProgram = [self programForShader];
    }
    return self;
}

#pragma mark -
#pragma mark Overriden methods

- (void)setUniformsForFragmentShader
{
	glUniform4fv(_colorTrasformLocation, 2, _colorTransform);
}

#pragma mark -
#pragma mark Public methods

#pragma mark -
#pragma mark Private methods

- (void)updateTextureWithEffects
{
    if (self.blurRadius.width == 0 && self.blurRadius.height == 0)
    {
        [self setTexture:self.initialTexture];
        [self setTextureRect:self.initialTextureRect rotated:NO untrimmedSize:self.initialTextureRect.size];
        [self setFlipY:NO];
    }
    else
    {
        GAFPreprocessedTexture* texture = [[GAFEffectPreprocessor sharedInstance] gaussianBlurredTextureFromTexture:self.initialTexture
                                                                                                              frame:self.initialTextureRect
                                                                                                        blurredSize:CGSizeMake(self.blurRadius.width, self.blurRadius.height)];
        if (texture != nil)
        {
            [self setTexture:texture.texture];
            [self setFlipY:YES];
            [self setTextureRect:texture.frame];
            [self setPostprocessedFrame:texture.frame];
            [self setPostprocessedScale:(1.0f / texture.scale)];
        }
    }
}

- (CCGLProgram *)programForShader
{
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGAFSpriteWithAlphaShaderProgramCacheKey];
    if (program == nil)
    {
        program = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert
                                              fragmentShaderFilename:kAlphaFragmentShaderFilename];
        
        if (program != nil)
        {
            [program addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
            [program addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
            [program addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            CHECK_GL_ERROR_DEBUG();
            
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGAFSpriteWithAlphaShaderProgramCacheKey];
        }
        else
        {
            CCLOGWARN(@"Cannot load program for GAFSpriteWithAlpha.");
            return nil;
        }
    }
    
    [program use];
    
    _colorTrasformLocation = (GLuint)glGetUniformLocation(program->_program, "colorTransform");
    
    if (_colorTrasformLocation <= 0)
    {
        CCLOGWARN(@"Cannot get uniforms for kGAFSpriteWithAlphaShaderProgramCacheKey");
    }
    
    return program;
}

- (void)setBlendingFunc
{
	ccBlendFunc bf;
    bf.src = GL_ONE;
	bf.dst = GL_ONE_MINUS_SRC_ALPHA;
	self.blendFunc = bf;
}

@end