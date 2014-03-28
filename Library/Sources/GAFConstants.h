//
//  NSObject_GAFConstants.h
//  GAFPlayer
//
//  Created by Sergey Sergeev on 12/13/13.
//  Copyright (c) 2013 CatalystApps. All rights reserved.
//

static NSString* const kGAFgaussianBlurCacheKey = @"gaf_ShaderGaussianBlur";
static NSString* const kGAFgaussianBlurVSName = @"gaf_ShaderGaussianBlur.vs";
static NSString* const kGAFgaussianBlurFSName = @"gaf_ShaderGaussianBlur.fs";

static NSString* const kGAFGlowCacheKey = @"gaf_ShaderGlow";
static NSString* const kGAFGlowVSName = @"gaf_ShaderGlow.vs";
static NSString* const kGAFGlowFSName = @"gaf_ShaderGlow.fs";
static NSString* const kGAFGlowColorUniName = @"glowColor";

static NSString* const kGAFgaussianBlurShaderUniformTexelWidthOffset = @"u_texelWidthOffset";
static NSString* const kGAFgaussianBlurShaderUniformTexelHeightOffset = @"u_texelHeightOffset";
static CGFloat   const kGAFgaussianKernelSize = 9;
static CGFloat   const kGAFgaussianTextureAtlasWidth = 2048;
static CGFloat   const kGAFgaussianTextureAtlasHeight = 2048;
static CGFloat   const kGAFgaussianBlurredSizeNoiseIgnored = 0.3f;
static CGFloat   const kGAFgaussianBlurredFrameNoiseIgnored = 1.0f;

