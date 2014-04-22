////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFAsset.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFAsset.h"
#import "GAFTextureAtlas.h"
#import "GAFSubobjectState.h"
#import "GAFAnimationFrame.h"
#import "GAFAnimationSequence.h"
#import "GAFAnimatedObject.h"
#import "NSString+GAFExtensions.h"
#import "GAFAssetExtendedDataObject.h"

#import "GAFSprite.h"

#import "GAFLoader.h"

#import "Support/CCFileUtils.h"

// Private interface

@interface GAFAsset ()

@property (nonatomic, assign) NSUInteger          majorVersion;
@property (nonatomic, assign) NSUInteger          minorVersion;

@property (nonatomic, strong) GAFTextureAtlas     *textureAtlas;
@property (nonatomic, assign) CGFloat             usedAtlasContentScaleFactor;

@property (nonatomic, strong) NSDictionary        *objects;

@property (nonatomic, strong) NSDictionary        *masks;

@property (nonatomic, strong) NSMutableDictionary *extendedDataObjectGroups;

@property (nonatomic, assign) CGRect              boundingBox;
@property (nonatomic, assign) CGPoint             pivotPoint;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation

@implementation GAFAsset

#pragma mark -
#pragma mark Properties

+ (BOOL)isAssetVersionPlayable:(NSString *)version
{
	// at this moment we do not have legacy animations, in future we may need to do something
	return YES;
}

#pragma mark -
#pragma mark Initialization & Release


- (id) initWithGAFFile:(NSString *)aGAFfilePath keepImagesInAtlas:(BOOL)aKeepImagesInAtlas
{
    return [self initWithGAFFile:aGAFfilePath atlasesDataDictionary:nil orAtlasTexturesFolder:nil extendedDataObjectClasses:nil keepImagesInAtlas:aKeepImagesInAtlas];
}

- (id) initWithGAFFileData:(NSData*)aGAFFileData
     atlasesDataDictionary:(NSDictionary *)anAtlasesDataDictionary
     orAtlasTexturesFolder:(NSString *)anAtlasTexturesFolder
 extendedDataObjectClasses:(NSDictionary *)anExtendedDataObjectClasses
         keepImagesInAtlas:(BOOL)aKeepImagesInAtlas
{
    self = [super init];
    
    self.textureAtlases = [NSMutableArray array];
    self.animationObjects = [NSMutableDictionary dictionary];
    self.animationMasks = [NSMutableDictionary dictionary];
    self.animationFrames = [NSMutableArray array];
    self.animationSequences = [NSMutableDictionary dictionary];
    
    GAFLoader* loader = new GAFLoader();
    
    bool isLoaded = loader->loadFile(aGAFFileData, self);
    
    if (isLoaded)
    {
        isLoaded &= [self loadTextures:anAtlasTexturesFolder];
    }
    
    delete loader;
    
    if (isLoaded)
        return  self;
    else
        return nil;
}

//! Binary GAF initializers here:
- (id) initWithGAFFile:(NSString *)aGAFFilePath
 atlasesDataDictionary:(NSDictionary *)anAtlasesDataDictionary
 orAtlasTexturesFolder:(NSString *)anAtlasTexturesFolder
extendedDataObjectClasses:(NSDictionary *)anExtendedDataObjectClasses
     keepImagesInAtlas:(BOOL)aKeepImagesInAtlas;
{
    self = [super init];
    
    self.textureAtlases = [NSMutableArray array];
    self.animationObjects = [NSMutableDictionary dictionary];
    self.animationMasks = [NSMutableDictionary dictionary];
    self.animationFrames = [NSMutableArray array];
    self.animationSequences = [NSMutableDictionary dictionary];
     
    GAFLoader* loader = new GAFLoader();
    
    bool isLoaded = loader->loadFile(aGAFFilePath, self);
    
    if (isLoaded)
    {
        if (anAtlasTexturesFolder == nil)
        {
            anAtlasTexturesFolder = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:aGAFFilePath];
            anAtlasTexturesFolder = [anAtlasTexturesFolder stringByDeletingLastPathComponent];
        }
        
        isLoaded &= [self loadTextures:anAtlasTexturesFolder];
    }
    
    delete loader;
    
    if (isLoaded)
        return  self;
    else
        return nil;
}

- (BOOL) loadTextures:(NSString*)anAtlasTexturesFolder
{
    self.textureAtlas = [self.textureAtlases objectAtIndex:0];
    float atlasScale = self.textureAtlas.scale;
    CGFloat currentDeviceScale = CC_CONTENT_SCALE_FACTOR();
    
    for (NSUInteger i = 1; i < [self.textureAtlases count]; ++i)
    {
        GAFTextureAtlas* atl = [self.textureAtlases objectAtIndex:i];
        float as = atl.scale;
        
        if (fabs(atlasScale - currentDeviceScale) > fabs(as - currentDeviceScale))
        {
            self.textureAtlas = atl;
            atlasScale = as;
        }
    }
    
    self.usedAtlasContentScaleFactor = atlasScale;
    
    BOOL loadingResult = NO;
    
    if (self.textureAtlas)
    {
        loadingResult = [self.textureAtlas loadImages:anAtlasTexturesFolder keepImagesInAtlas:NO];
    }
    
    return loadingResult;
}

#pragma mark -
#pragma mark Overriden methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"< %@ - 0x%x | version - %lu.%lu | objects - %lu | masks - %lu | frames - %lu >",
            NSStringFromClass(self.class), (unsigned long)self,
            (unsigned long)self.majorVersion, (unsigned long)self.minorVersion,
            (unsigned long)self.objects.count, (unsigned long)self.masks.count, (unsigned long)self.animationFrames.count];
}

#pragma mark -
#pragma mark Public methods

- (NSArray *)animationSequenceNames
{
    return [self.animationSequences allKeys];
}

- (GAFAnimationSequence *)animationSequenceForName:(NSString *)aName
{
	if (self.animationSequences == nil || aName == nil || ![aName length])
	{
		return nil;
	}
	return (GAFAnimationSequence *)_animationSequences[aName];
}

- (GAFAnimationSequence *)animationSequenceByLastFrame:(NSUInteger)aLastFrame
{
	if (self.animationSequences == nil)
	{
		return nil;
	}
	for (NSString *key in self.animationSequences)
	{
		GAFAnimationSequence *seq = (self.animationSequences)[key];
		if (aLastFrame == seq.frameEnd)
		{
			return seq;
		}
	}
	return nil;
}

#pragma mark -
#pragma mark Private methods

#if 0

- (void)loadFramesFromConfigDictionary:(NSDictionary *)aConfigDictionary
{
    NSAssert(_objects != nil, @"self.objects != nil");
    if (_objects == nil)
    {
        CCLOGWARN(@"ERROR: in loadFramesFromConfigDictionary. self.objects property should be initialized.");
        return;
    }
    
    @autoreleasepool
    {
        NSMutableDictionary *currentStates = [[NSMutableDictionary alloc] initWithCapacity:[_objects count]];
        NSMutableArray *mAnimationFrames = [NSMutableArray array];
        
        NSArray *animationConfigFrames = aConfigDictionary[@"animationConfigFrames"];
        
        // Create default states for all objects in self.animationObjects
        for (NSString *key in _objects)
        {
            GAFSubobjectState *state = [[GAFSubobjectState alloc] initEmptyStateWithObjectId:key];
            currentStates[key] = state;
        }
        // Processing frames
        NSUInteger configFrameCount = (NSUInteger)[aConfigDictionary[kAnimationFrameCountKey] integerValue];
        if (configFrameCount == 0)
        {
            CCLOGWARN(@"ERROR: initializing GAFAsset.  configFrameCount is 0 or pmpty");
            return;
        }
        NSUInteger configFrameIndex = 0;
        for (NSUInteger index = 0; index < configFrameCount; ++index)
        {
            if (configFrameIndex < [animationConfigFrames count])
            {
                NSDictionary *configFrame = animationConfigFrames[configFrameIndex];
                NSInteger configFrameNo = [configFrame[kFrameNumberKey] integerValue];
                
                if (configFrameNo - 1 == index) // -1 because frame numbers start with 1
                {
                    // Update current object states
                    NSArray *newStates = [self objectStatesFromConfigFrame:configFrame];
                    
                    for (GAFSubobjectState *state in newStates)
                    {
                        currentStates[state.objectId] = state;
                    }
                    
                    configFrameNo ++;
                    configFrameIndex ++;
                }
            }
            
            // Add frame
            GAFAnimationFrame *frame = [[GAFAnimationFrame alloc] init];
            
            frame.objectsStates = [[currentStates allValues] copy]; //TODO 2b||!2b copy?
            
            [mAnimationFrames addObject:frame];
        }        
        self.animationFrames = mAnimationFrames;
    }
}

- (void)loadAnimationSequences:(NSArray *)aSequencesNodes
{
    static NSString * const kPCAnimationSequenceIdKey = @"id";
    static NSString * const kPCAnimationSequenceStartFrameNoKey = @"startFrameNo";
    static NSString * const kPCAnimationSequenceEndFrameNoKey = @"endFrameNo";
    
    @autoreleasepool
    {
        NSMutableDictionary *mutSequences = [[NSMutableDictionary alloc] initWithCapacity:aSequencesNodes.count];
        for (NSDictionary *sequenceNode in aSequencesNodes)
        {
            NSString *sequenceId = sequenceNode[kPCAnimationSequenceIdKey];
            NSNumber *startFrameNo = sequenceNode[kPCAnimationSequenceStartFrameNoKey];
            NSNumber *endFrameNo = sequenceNode[kPCAnimationSequenceEndFrameNoKey];
            
            if (sequenceId != nil && startFrameNo != nil && endFrameNo != nil)
            {
                GAFAnimationSequence *sequence =
                [[GAFAnimationSequence alloc] initWithName:sequenceId
                                                   framesRange:NSMakeRange([startFrameNo integerValue] - 1,
                                                                           [endFrameNo integerValue] - [startFrameNo integerValue])];
                
                mutSequences[sequenceId] = sequence;
            }
            else
            {
                CCLOGWARN(@"Error while creating PCAnimationData. ConfigData cannot be parsed.");
            }
        }
        
        self.animationSequences = mutSequences;
    }
}

- (NSArray *)objectStatesFromConfigFrame:(NSDictionary *)configFrame
{
	if (configFrame == nil)
	{
		return nil;
	}
    NSDictionary *stateNodes = (NSDictionary*)configFrame[kFrameStateKey];
    NSMutableArray *states = [NSMutableArray arrayWithCapacity:[stateNodes count]];
    
    for (NSString *key in stateNodes)
    {
        GAFSubobjectState *state = [[GAFSubobjectState alloc] initWithStateDictionary:stateNodes[key] objectId:key];
        if (state != nil)
        {
            [states addObject:state];
        }
        else
        {
            CCLOGWARN(@"GAFSubobjectState cannot be created. Ignoring.");
        }
    }
    return states;
}

- (CGFloat)atlasScaleFromAtlasConfig:(NSDictionary *)anAtlasConfigDictionary
{
	if (anAtlasConfigDictionary == nil)
	{
		return 0;
	}
	NSNumber *scale = (NSNumber *)anAtlasConfigDictionary[kAtlasScaleKey];
    return (scale != nil) ? [scale floatValue] : 0;
}

#endif

@end
