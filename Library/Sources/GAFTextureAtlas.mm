////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFTextureAtlas.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFTextureAtlas.h"
#import "GAFTextureAtlasElement.h"
#import "CCTexture2D.h"
#import "Support/CCFileUtils.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static NSString * const kAtlasesKey      = @"atlases";
static NSString * const kElementsKey     = @"elements";
static NSString * const kSourcesKey      = @"sources";
static NSString * const kSourceKey       = @"source";
static NSString * const kCSFKey          = @"csf";
static NSString * const kTextureAtlasKey = @"textureAtlas";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFTextureAtlas ()

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *textures;
@property (nonatomic, strong) NSMutableArray* atlasInfos;

- (void)loadElementsFromAnimationConfigDictionary:(NSDictionary *)aConfigDictionary;

- (void)generateTexturesFromImages;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GAFTextureAtlas

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initialization & Release

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        self.images = [[NSMutableArray alloc] initWithCapacity:1];
        self.textures = [[NSMutableArray alloc] initWithCapacity:1];
        
        self.loaded = NO;
    }
    return self;
}

- (id)initWithTextureAtlasesDictionary:(NSDictionary *)aTextureAtlasesDictionary
          textureAtlasConfigDictionary:(NSDictionary *)aTextureAtlasConfigDictionary
                     keepImagesInAtlas:(BOOL)aKeepImagesInAtlas
{
    NSAssert(aTextureAtlasesDictionary != nil && aTextureAtlasConfigDictionary != nil, @"parameters should not equal to nil");
    if (aTextureAtlasesDictionary == nil)
    {
        CCLOGWARN(@"ERROR: initializing TextureAtlas. aTextureAtlasesDictionary not present");
        return nil;
    }
    if (aTextureAtlasConfigDictionary == nil)
    {
        CCLOGWARN(@"ERROR: initializing TextureAtlas. aTextureAtlasConfigDictionary not present");
        return nil;
    }
    
    if ((self = [self init]))
    {
        NSArray *atlasesInfo = aTextureAtlasConfigDictionary[kAtlasesKey];
        // Order by atlas id
        atlasesInfo = [atlasesInfo sortedArrayUsingComparator:
                       ^NSComparisonResult(id obj1, id obj2)
                       {
                           NSDictionary *info1 = (NSDictionary *)obj1;
                           NSDictionary *info2 = (NSDictionary *)obj2;
                           NSInteger id1 = [info1[@"id"] integerValue];
                           NSInteger id2 = [info2[@"id"] integerValue];
                           if (id2 > id1)
                               return NSOrderedAscending;
                           else if (id2 < id1)
                               return NSOrderedDescending;
                           else
                               return NSOrderedSame;
                       }];
        
        // Load textures from Data dictionary for each mentioned atlas
        if (atlasesInfo != nil && atlasesInfo.count > 0)
        {
            for (NSDictionary *atlasInfo in atlasesInfo)
            {
                NSArray *sources = atlasInfo[kSourcesKey];
                if (sources == nil)
                {
                    CCLOGWARN(@"ERROR: initializing sources. sources not present");
                    return nil;
                }
                
                NSUInteger desiredCsf = 1;
                
                if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                    ([UIScreen mainScreen].scale == 2.0))
                {
                    desiredCsf = 2;
                }
                
                NSString * source = nil;
                NSUInteger csf = 0;
                for (NSDictionary * csfdict in sources)
                {
                    csf = [csfdict[kCSFKey] unsignedIntegerValue];
                    NSString * s = (NSString *)csfdict[kSourceKey];
                    if (1 == csf)
                    {
                        source = s;
                    }
                    if (csf == desiredCsf)
                    {
                        source = s;
                        break;
                    }
                }
                
                if (csf == 0)
                {
                    CCLOGWARN(@"ERROR: initializing sources.  csf not present");
                    return nil;
                }
                if (source == nil)
                {
                    CCLOGWARN(@"ERROR: initializing sources.  source not present");
                    return nil;
                }
                
                NSData *atlasTextureData = aTextureAtlasesDictionary[source];
                if (atlasTextureData != nil)
                {
                    UIImage *image = [[UIImage alloc] initWithData:atlasTextureData scale:csf];
                    if (image == nil)
                    {
                        CCLOGWARN(@"Cannot create UIImage for texture name(key) - %@", source);
                        return nil;
                    }
                    [self.images addObject:image];
                }
                else
                {
                    CCLOGWARN(@"Cannot find texture for name(key) - %@", source);
                    return nil;
                }
            }
        }
        
        [self loadElementsFromAnimationConfigDictionary:aTextureAtlasConfigDictionary];
        [self generateTexturesFromImages];
        if (!aKeepImagesInAtlas)
        {
            [self releaseImages];
        }
    }
    return self;
}

- (id)initWithTexturesDirectory:(NSString *)aTexturesDirectory
   textureAtlasConfigDictionary:(NSDictionary *)aTextureAtlasConfigDictionary
              keepImagesInAtlas:(BOOL)aKeepImagesInAtlas
{
    NSAssert(aTexturesDirectory != nil && aTextureAtlasConfigDictionary != nil, @"parameters should not equal to nil");
    if (aTexturesDirectory == nil)
    {
        CCLOGWARN(@"ERROR: initializing TextureAtlas. aTexturesDirectory not present");
        return nil;
    }
    if (aTextureAtlasConfigDictionary == nil)
    {
        CCLOGWARN(@"ERROR: initializing TextureAtlas. aTextureAtlasConfigDictionary not present");
        return nil;
    }
    
    if ((self = [self init]))
    {
        NSArray *atlasesInfo = aTextureAtlasConfigDictionary[kAtlasesKey];
        // Order by atlas id
        atlasesInfo = [atlasesInfo sortedArrayUsingComparator:
                       ^NSComparisonResult(id obj1, id obj2)
                       {
                           NSDictionary *info1 = (NSDictionary *)obj1;
                           NSDictionary *info2 = (NSDictionary *)obj2;
                           NSInteger id1 = [info1[@"id"] integerValue];
                           NSInteger id2 = [info2[@"id"] integerValue];
                           if (id2 > id1)
                               return NSOrderedAscending;
                           else if (id2 < id1)
                               return NSOrderedDescending;
                           else
                               return NSOrderedSame;
                       }];
        
        // Load textures for each mentioned atlas
        if (atlasesInfo != nil && atlasesInfo.count > 0)
        {
            for (NSDictionary *atlasInfo in atlasesInfo)
            {
                NSArray *sources = atlasInfo[kSourcesKey];
                if(sources == nil)
                {
                    CCLOGWARN(@"ERROR: initializing sources. 'sources' not present");
                    return nil;
                }
                NSUInteger desiredCsf = 1;
                NSUInteger realCsf = 1;
                
                if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                    ([UIScreen mainScreen].scale == 2.0))
                {
                    desiredCsf = 2;
                }
                
                NSUInteger csf = 0;
                NSString * source = nil;
                for (NSDictionary * csfdict in sources)
                {
                    csf = [csfdict[kCSFKey] unsignedIntegerValue];
                    NSString * s = (NSString *)csfdict[kSourceKey];
                    if (1 == csf)
                    {
                        source = s;
                    }
                    if (csf == desiredCsf)
                    {
                        source = s;
                        realCsf = csf;
                        break;
                    }
                }
                
                if (csf == 0)
                {
                    CCLOGWARN(@"ERROR: initializing sources. 'csf' not present");
                    return nil;
                }
                if (source == nil)
                {
                    CCLOGWARN(@"ERROR: initializing sources. 'source' not present");
                    return nil;
                }
                
                NSData *imageData = [NSData dataWithContentsOfFile:[aTexturesDirectory stringByAppendingPathComponent:source]];
                if (imageData == nil)
                {
                    CCLOGWARN(@"Cannot load imageData for name(key) - %@", source);
                    return nil;
                }
                UIImage *image = [[UIImage alloc] initWithData:imageData scale:realCsf];
                if (image == nil)
                {
                    CCLOGWARN(@"Cannot create UIImage for texture for name(key) - %@", source);
                    return nil;
                }
                [self.images addObject:image];
            }
        }
        
        [self loadElementsFromAnimationConfigDictionary:aTextureAtlasConfigDictionary];
        [self generateTexturesFromImages];
        if (!aKeepImagesInAtlas)
        {
            [self releaseImages];
        }
    }
    return self;
}


- (void)pushAtlasInfo:(AtlasInfo *)anAtlasInfo
{
    [self.atlasInfos addObject:anAtlasInfo];
}


- (id)initWithImages:(NSArray *)anImagesArray
       atlasElements:(NSDictionary *)anAtlasElements
    generateTextures:(BOOL)aGenerateTextures
{
    if (anImagesArray == nil)
    {
        CCLOGWARN(@"ERROR: initializing TextureAtlas. anImagesArray not present");
        return nil;
    }
    if (anAtlasElements == nil)
    {
        CCLOGWARN(@"ERROR: initializing TextureAtlas. anAtlasElements not present");
        return nil;
    }
    
    if ((self = [self init]))
    {
        self.images = [anImagesArray mutableCopy];
        self.elements = [anAtlasElements copy];
        
        self.loaded = YES;
        
        if (aGenerateTextures)
        {
            [self generateTexturesFromImages];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Public methods

- (BOOL)loadImages:(NSString *)aTexturesDirectory keepImagesInAtlas:(BOOL)aKeepImagesInAtlas;
{
    self.atlasInfos = [NSMutableArray arrayWithArray:[self.atlasInfos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                      {
                          AtlasInfo* ai1 = (AtlasInfo*)obj1;
                          AtlasInfo* ai2 = (AtlasInfo*)obj2;
                          return ai1.idx < ai2.idx;
                      }]];
    
    NSUInteger desiredCsf = 1;
    NSUInteger realCsf = 1;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0))
    {
        desiredCsf = 2;
    }
    
    if (self.atlasInfos && self.atlasInfos.count > 0)
    {
        
        NSString* source = nil;
        
        for (NSUInteger i = 0; i < self.atlasInfos.count; ++i)
        {
            AtlasInfo* info = [self.atlasInfos objectAtIndex:i];

            for (NSUInteger j = 0; i < info.sources.count; ++i)
            {
                Source* aiSource = [info.sources objectAtIndex:j];
                if (1.f == aiSource.csf)
                {
                    source = aiSource.source;
                }
                
                if (aiSource.csf == desiredCsf)
                {
                    source = aiSource.source;
                    realCsf = aiSource.csf;
                    break;
                }
            }
            
            if (source == nil)
            {
                CCLOGWARN(@"ERROR: initializing sources. 'source' not present");
                return NO;
            }
            
            NSData *imageData = [NSData dataWithContentsOfFile:[aTexturesDirectory stringByAppendingPathComponent:source]];
            
            if (imageData == nil)
            {
                CCLOGWARN(@"Cannot load imageData for name(key) - %@", source);
                return nil;
            }
            
            UIImage *image = [[UIImage alloc] initWithData:imageData scale:realCsf];
            
            if (image == nil)
            {
                CCLOGWARN(@"Cannot create UIImage for texture for name(key) - %@", source);
                return nil;
            }
            
            [self.images addObject:image];
        }
    }
    
    [self generateTexturesFromImages];
    if (!aKeepImagesInAtlas)
    {
        [self releaseImages];
    }
    
    return YES;
}

- (void)releaseImages
{
    if (self.images.count > 0)
    {
        if (self.images.count == self.textures.count)
        {
            [self.images removeAllObjects];
        }
        else
        {
            CCLOGWARN(@"GAFTextureAtlas images cannot be released as textures were not created, releasing of images will lead to complete image data loss");
        }
    }
}

#pragma mark -
#pragma mark Private methods

- (void)generateTexturesFromImages
{
    if (self.images.count == 0)
        return;
    
    if ([EAGLContext currentContext] == nil)
    {
        CCLOGWARN(@"Cannot create CCTexture2D in GAFTextureAtlas because there is no EAGLContext in thread %@", [NSThread currentThread]);
        return;
    }
    
    for (UIImage *image in self.images)
    {
        // kCCResolutioniPad kCCResolutioniPadRetinaDisplay // should not be used - it should work universally across the platforms
        CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage:image.CGImage resolutionType:kCCResolutioniPadRetinaDisplay];
        [self.textures addObject:texture];
    }
}

- (void)loadElementsFromAnimationConfigDictionary:(NSDictionary *)aConfigDictionary
{
    if (aConfigDictionary == nil)
    {
        CCLOGWARN(@"Error in loadElementsFromAnimationConfigDictionary. aConfigDictionary is nil.");
        return;
    }
    
    NSArray *nElements = aConfigDictionary[kElementsKey];
    
    if (nElements != nil)
    {
        @autoreleasepool
        {
            NSMutableDictionary *parsedElements = [[NSMutableDictionary alloc] initWithCapacity:[nElements count]];
            for (id nElement in nElements)
            {
                if ([nElement isKindOfClass:[NSDictionary class]])
                {
                    GAFTextureAtlasElement *element =
                        [[GAFTextureAtlasElement alloc] initWithDictionary:(NSDictionary *)nElement];
                    if (element != nil)
                    {
                        parsedElements[element.name] = element;
                    }
                }
                else
                {
                   CCLOGWARN(@"Error when parsing texture atlas element JSON. Atlas element not of NSDictionary type.");
                }
            }
            self.elements = parsedElements;
        }
    }
    else
    {
        CCLOGWARN(@"Error when parsing texture atlas element JSON.");
        return;
    }
    
    self.loaded = YES;
}

@end