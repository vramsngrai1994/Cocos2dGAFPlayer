//
//  GAFEffectPreprocessor.m
//  GAFPlayer
//
//  Created by Sergey Sergeev on 12/13/13.
//  Copyright (c) 2013 CatalystApps. All rights reserved.
//

#import "GAFCommon.h"
#import "GAFConstants.h"
#import "GAFEffectPreprocessor.h"
#import "GAFCustomAtlasPreprocessor.h"

@interface GAFCachedBlurredTexture : NSObject

@property(nonatomic, assign) CGRect precomputedFrame;

@property(nonatomic, strong) CCTexture2D* sourceTexture;
@property(nonatomic, assign) CGRect sourceFrame;
@property(nonatomic, assign) CGSize sourceBlurredSize;
@property(nonatomic, assign) CGFloat scale;

- (id)initWithSourceTexture:(CCTexture2D*)sourceTexture
       withPrecomputedFrame:(CGRect)precomputedFrame
            withSourceFrame:(CGRect)sourceFrame
      withSourceBlurredSize:(CGSize)sourceBlurredSize
                  withScale:(CGFloat)scale;

- (BOOL)isEqualToSourceTexture:(CCTexture2D*)sourceTexture
               withSourceFrame:(CGRect)sourceFrame
         withSourceBlurredSize:(CGSize)sourceBlurredSize;

@end

@implementation GAFCachedBlurredTexture

- (id)initWithSourceTexture:(CCTexture2D *)sourceTexture
       withPrecomputedFrame:(CGRect)precomputedFrame
            withSourceFrame:(CGRect)sourceFrame
      withSourceBlurredSize:(CGSize)sourceBlurredSize
                  withScale:(CGFloat)scale
{
    if ((self = [super init]))
    {
        _precomputedFrame = precomputedFrame;
        
        _sourceTexture = sourceTexture;
        _sourceFrame = sourceFrame;
        _sourceBlurredSize = sourceBlurredSize;
        _scale = scale;
    }
    return self;
}

- (BOOL)isEqualToSourceTexture:(CCTexture2D *)sourceTexture
               withSourceFrame:(CGRect)sourceFrame
         withSourceBlurredSize:(CGSize)sourceBlurredSize
{
    return [sourceTexture isEqual:self.sourceTexture] &&
    GAF_CGRectEqualToRect(sourceFrame, self.sourceFrame, kGAFgaussianBlurredFrameNoiseIgnored) &&
    GAF_CGSizeEqualToSize(sourceBlurredSize, self.sourceBlurredSize, kGAFgaussianBlurredSizeNoiseIgnored);
}

@end

@interface GAFPreprocessedTexture()

- (id)initWithTexture:(CCTexture2D*)texture withFrame:(CGRect)frame withScale:(CGFloat)scale;

@end

@implementation GAFPreprocessedTexture

- (id)initWithTexture:(CCTexture2D *)texture withFrame:(CGRect)frame withScale:(CGFloat)scale
{
    self = [super init];
    if (self)
    {
        _texture = texture;
        _frame = frame;
        _scale = scale;
    }
    return self;
}

@end

@interface GAFEffectPreprocessor()

@property(nonatomic, strong) GAFCustomAtlasPreprocessor* customAtlasPreprocessor;
@property(nonatomic, strong) CCRenderTexture* frameBuffer;
@property(nonatomic, strong) NSMutableArray* cachedBlurredTextures;
@property(nonatomic, strong) CCGLProgram* shader;
@property(nonatomic, assign) GLint shaderUniformTexelWidthOffset;
@property(nonatomic, assign) GLint shaderUniformTexelHeightOffset;

@end

@implementation GAFEffectPreprocessor

+ (GAFEffectPreprocessor *)sharedInstance
{
    static dispatch_once_t once;
    static id instance = nil;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
#if defined(__ENABLE_EFFECT_PREPROCESSING_CACHING__)
        
        _frameBuffer = [CCRenderTexture renderTextureWithWidth:kGAFgaussianTextureAtlasWidth
                                                        height:kGAFgaussianTextureAtlasHeight
                                                   pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        _cachedBlurredTextures = [NSMutableArray new];
        _customAtlasPreprocessor = [GAFCustomAtlasPreprocessor new];
        
#endif
    }
    return self;
}

- (GAFPreprocessedTexture*)gaussianBlurredTextureFromTexture:(CCTexture2D *)sourceTexture
                                                       frame:(CGRect)sourceFrame
                                                    blurredSize:(CGSize)blurredSize;
{
#if defined(__ENABLE_EFFECT_PREPROCESSING_CACHING__)
    
    NSArray* cachedBlurredTextures = [self.cachedBlurredTextures filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        GAFCachedBlurredTexture* texture = evaluatedObject;
        return [texture isEqualToSourceTexture:sourceTexture withSourceFrame:sourceFrame withSourceBlurredSize:blurredSize] ? YES : NO;
    }]];
    
    if([cachedBlurredTextures count] != 0)
    {
        GAFCachedBlurredTexture* texture = [cachedBlurredTextures objectAtIndex:0];
        return [[GAFPreprocessedTexture alloc] initWithTexture:self.frameBuffer.sprite.texture withFrame:texture.precomputedFrame withScale:texture.scale];
    }
    
#endif
    
    CGSize blurredTextureSize = CGSizeMake(sourceFrame.size.width + 2 * (kGAFgaussianKernelSize / 2) * blurredSize.width,
                                           sourceFrame.size.height + 2 * (kGAFgaussianKernelSize / 2) * blurredSize.height);

    CGFloat scale = 1.0f;
    
#if defined(__ENABLE_EFFECT_PREPROCESSING_CACHING__)
    
    if(blurredTextureSize.width > blurredTextureSize.height)
    {
        scale = sourceFrame.size.width / blurredTextureSize.width;
    }
    else
    {
        scale = sourceFrame.size.height / blurredTextureSize.height;
    }
    
#endif

    blurredTextureSize.width *= scale;
    blurredTextureSize.height *= scale;
    
    CCRenderTexture *accessoryFrameBuffer_01 = [CCRenderTexture renderTextureWithWidth:blurredTextureSize.width
                                                                                height:blurredTextureSize.height
                                                                           pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    CCRenderTexture *accessoryFrameBuffer_02 = [CCRenderTexture renderTextureWithWidth:blurredTextureSize.width
                                                                                height:blurredTextureSize.height
                                                                           pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    {
        CCSprite *sprite = [CCSprite spriteWithTexture:sourceTexture rect:sourceFrame];
        [sprite setScale:scale];
        sprite.position = CGPointMake(blurredTextureSize.width / 2,
                                      blurredTextureSize.height / 2);
        [sprite setBlendFunc:(ccBlendFunc){ GL_ONE, GL_ZERO }];
        [accessoryFrameBuffer_01 beginWithClear:0.0 g:0.0 b:0.0 a:0.0];
        [sprite visit];
        [accessoryFrameBuffer_01 end];
        
    }
    CHECK_GL_ERROR_DEBUG();
    
    {
        GLfloat texelWidthValue = blurredSize.width / blurredTextureSize.width;
        GLfloat texelHeightValue = 0;
        
        accessoryFrameBuffer_01.sprite.position = CGPointMake(blurredTextureSize.width / 2,
                                                                 blurredTextureSize.height / 2);
        
        accessoryFrameBuffer_01.sprite.shaderProgram = self.shader;
        
        [self.shader use];
        [self.shader setUniformLocation:self.shaderUniformTexelWidthOffset withF1:texelWidthValue];
        [self.shader setUniformLocation:self.shaderUniformTexelHeightOffset withF1:texelHeightValue];
        
        [accessoryFrameBuffer_01.sprite setBlendFunc:(ccBlendFunc){ GL_ONE, GL_ZERO }];
        
        [accessoryFrameBuffer_02 beginWithClear:0.0 g:0.0 b:0.0 a:0.0];
        [accessoryFrameBuffer_01.sprite visit];
        [accessoryFrameBuffer_02 end];
    }
    CHECK_GL_ERROR_DEBUG();
    
    {
        GLfloat texelWidthValue = 0;
        GLfloat texelHeightValue = blurredSize.height / blurredTextureSize.height;
        
        accessoryFrameBuffer_02.sprite.position = CGPointMake(blurredTextureSize.width / 2,
                                                                          blurredTextureSize.height / 2);
        
        accessoryFrameBuffer_02.sprite.shaderProgram = self.shader;
        
        [self.shader use];
        [self.shader setUniformLocation:self.shaderUniformTexelWidthOffset withF1:texelWidthValue];
        [self.shader setUniformLocation:self.shaderUniformTexelHeightOffset withF1:texelHeightValue];
        
        [accessoryFrameBuffer_02.sprite setBlendFunc:(ccBlendFunc){ GL_ONE, GL_ZERO }];
        
        [accessoryFrameBuffer_01 beginWithClear:0.0 g:0.0 b:0.0 a:0.0];
        [accessoryFrameBuffer_02.sprite visit];
        [accessoryFrameBuffer_01 end];
    }
    CHECK_GL_ERROR_DEBUG();
    
#if defined(__ENABLE_EFFECT_PREPROCESSING_CACHING__)
    
    CGRect frame = [self.customAtlasPreprocessor frameForTextureWithFrame:CGRectMake(0, 0, blurredTextureSize.width, blurredTextureSize.height)];
    NSAssert(!CGRectEqualToRect(frame, CGRectZero), @"Error: can't allocate frame in the current Texture Altas"); // TODO : create texture atlas builder.
    NSAssert(CGSizeEqualToSize(frame.size, blurredTextureSize), @"Error: calculated wrong cached size");
    
    for(GAFCachedBlurredTexture* texture in self.cachedBlurredTextures)
    {
        CGRect precomputedFrame = texture.precomputedFrame;
        NSAssert(!CGRectIntersectsRect(frame, precomputedFrame), @"Error; calculated frames intersected");
    }
    
    {
        CGPoint position = CGPointMake(frame.origin.x + frame.size.width / 2.0f,
                                       frame.origin.y + frame.size.height / 2.0f);
        accessoryFrameBuffer_02.sprite.position = position;
        [accessoryFrameBuffer_02.sprite setBlendFunc:(ccBlendFunc){ GL_ONE, GL_ZERO }];
        
        if([self.cachedBlurredTextures count] == 0)
        {
            [self.frameBuffer beginWithClear:0.0 g:0.0 b:0.0 a:0.0];
        }
        else
        {
            [self.frameBuffer begin];
        }
        [accessoryFrameBuffer_02.sprite visit];
        [self.frameBuffer end];
    }
    CHECK_GL_ERROR_DEBUG();
    
    [self.cachedBlurredTextures addObject:[[GAFCachedBlurredTexture alloc] initWithSourceTexture:sourceTexture withPrecomputedFrame:frame withSourceFrame:sourceFrame withSourceBlurredSize:blurredSize withScale:scale]];
    return [[GAFPreprocessedTexture alloc] initWithTexture:self.frameBuffer.sprite.texture withFrame:frame withScale:scale];
    
#else
    
    return [[GAFPreprocessedTexture alloc] initWithTexture:accessoryFrameBuffer_01.sprite.texture
                                                 withFrame:CGRectMake(0,
                                                                      0,
                                                                      accessoryFrameBuffer_01.sprite.contentSize.width,
                                                                      accessoryFrameBuffer_01.sprite.contentSize.height)
                                                 withScale:scale];
    
#endif
}

- (CCGLProgram *)shader
{
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:kGAFgaussianBlurCacheKey];
    if (program == nil)
    {
        program = [[CCGLProgram alloc] initWithVertexShaderFilename:kGAFgaussianBlurVSName
                                              fragmentShaderFilename:kGAFgaussianBlurFSName];
        
        if (program != nil)
        {
            [program addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
            [program addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
            
            [program link];
            [program updateUniforms];
            
            self.shaderUniformTexelWidthOffset = glGetUniformLocation(program->_program, [kGAFgaussianBlurShaderUniformTexelWidthOffset UTF8String]);
            self.shaderUniformTexelHeightOffset = glGetUniformLocation(program->_program, [kGAFgaussianBlurShaderUniformTexelHeightOffset UTF8String]);
            
            CHECK_GL_ERROR_DEBUG();
            [[CCShaderCache sharedShaderCache] addProgram:program forKey:kGAFgaussianBlurCacheKey];
        }
        else
        {
            CCLOGWARN(@"Cannot load program for %@.", kGAFgaussianBlurCacheKey);
            return nil;
        }
    }
    return program;
}


@end
