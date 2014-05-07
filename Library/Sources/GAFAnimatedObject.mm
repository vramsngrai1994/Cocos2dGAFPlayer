////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFAnimatedObject.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFAnimatedObject.h"
#import "GAFSprite.h"
#import "GAFTextureAtlas.h"
#import "GAFTextureAtlasElement.h"
#import "GAFNode.h"
#import "GAFSprite.h"
#import "GAFAsset.h"
#import "GAFSpriteWithAlpha.h"
#import "GAFAnimationFrame.h"
#import "GAFSubobjectState.h"
#import "GAFStencilMaskSprite.h"
#import "GAFAnimationSequence.h"
#import "GAFFilterData.h"
#import "CCSpriteFrame.h"
#import "NSString+GAFExtensions.h"
#import "CCDirector.h"
#import "GAFCommon.h"
#import "GAFFilterData.h"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFAnimatedObject ()

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) BOOL isRunning;

@property (nonatomic, strong) NSMutableDictionary *capturedObjects;    // [Key]:inner ids of captured objects [Value]:controlFlags

- (GAFSprite *)subObjectForInnerObjectId:(NSString *)anInnerObjectId;
- (NSString *)objectIdByObjectName:(NSString *)aName;

- (void)removeAllSubObjects;

- (void) instantiateObject:(NSDictionary*)anAnimationObjects
  animationMasksDictionary:(NSDictionary *)anAnimationMasks;

/// Processes animation frame that was already processed, doesn't move currentFrame pointer
/// (may be needed in case when subobject parameters were changed and require verification)
- (void)processCurrentAnimationFrameOnceMore;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GAFAnimatedObject

#pragma mark -
#pragma mark Properties

@synthesize asset;
@synthesize subObjects;
@synthesize masks;
@synthesize framePlayedDelegate;
@synthesize currentFrameIndex;
@synthesize totalFrameCount;
@synthesize isRunning;
@synthesize FPSType;
@synthesize extraFramesCounter;

#pragma mark -
#pragma mark Initialization & Release

+ (GAFAnimatedObject *)animatedObjectWithAsset:(GAFAsset *)anAsset
{
    return [[self alloc] initWithAsset:anAsset];
}

+ (GAFAnimatedObject *)animatedObjectWithPath:(NSString *)aGAFPath
{
    return [[self alloc] initWithPath:aGAFPath];
}

+ (GAFAnimatedObject *)animatedObjectWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped
{
    return [[self alloc] initWithPath:aGAFPath looped:isLooped];
}

+ (id)animatedObjectWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped andRun:(BOOL)run
{
    return [[self alloc] initWithPath:aGAFPath looped:isLooped andRun:run];
}

- (id)initWithAsset:(GAFAsset *)anAsset
{
    if(anAsset == nil)
    {
        CCLOGWARN(@"ERROR: initializing GAFAnimatedObject.  anAsset not present");
        return nil;
    }
    
	if ((self = [super init]))
	{
		if (anAsset == nil)
		{
			return nil;
		}
		self.asset = anAsset;
		self.subObjects = [NSMutableDictionary dictionary];
		self.masks = [NSMutableDictionary dictionary];
		_animationsSelectorScheduled = NO;
		self.FPSType = kGAFAnimationFPSType_60;
		self.extraFramesCounter = 0;
		self.currentSequenceStart = self.currentFrameIndex = GAF_FIRST_FRAME_INDEX;
        self.totalFrameCount = [self.asset.animationFrames count];
		self.currentSequenceEnd = self.totalFrameCount;
		self.isRunning = NO;
        
        self.isInitialized = NO;
        self.capturedObjects = [NSMutableDictionary new];
        
        self.externalTextureAtlases = [NSMutableDictionary dictionaryWithCapacity:0];
        self.hiddenSubobjectIds = [NSMutableArray array];
        self.contentSize = self.asset.boundingBox.size;
        self.anchorPoint = self.asset.pivotPoint;
        self.ignoreAnchorPointForPosition = YES;
	}
	return self;
}

- (id)initWithPath:(NSString *)aGAFPath
{
    return [self initWithPath:aGAFPath looped:NO andRun:NO];
}

- (id)initWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped
{
    return [self initWithPath:aGAFPath looped:isLooped andRun:NO];
}

- (id)initWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped andRun:(BOOL)run
{
    if(aGAFPath == nil)
    {
        CCLOGWARN(@"ERROR: initializing GAFAnimatedObject. aGAFPath not present.");
        return nil;
    }
    
    GAFAsset* assetData = [[GAFAsset alloc] initWithGAFFile:aGAFPath keepImagesInAtlas:NO];
    if(assetData !=nil)
    {
        if([self initWithAsset:assetData])
        {
            [self setIsLooped:isLooped];
            if(run)
                [self start];
            return self;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        CCLOGWARN(@"ERROR: initializing GAFAnimatedObject. assetData is nil");
        return nil;
    }
}

#pragma mark -
#pragma mark Public methods

- (CGRect)realBoundingBoxForCurrentFrame
{
    CGRect result = CGRectZero;
    for (GAFSprite *subObject in [self.subObjects allValues])
    {
        if (subObject.visible)
        {
            CGRect bb = [subObject boundingBox];
            result = CGRectUnion(result, bb);
        }
    }
    
    return CGRectApplyAffineTransform(result, [self nodeToParentTransform]);
}

- (void) instantiateObject:(NSDictionary*)anAnimationObjects
  animationMasksDictionary:(NSDictionary *)anAnimationMasks
{
    for (NSNumber* objectIdRef in anAnimationObjects)
    {
        CCSpriteFrame *spriteFrame = nil;
        
        NSNumber* atlasElementIdRef = anAnimationObjects[objectIdRef];
        
        GAFTextureAtlasElement* element = self.asset.textureAtlas.elements[atlasElementIdRef];
        
        if (nil != element)
        {
            if ([self.asset.textureAtlas.textures count] > [element.atlasIdx integerValue])
            {
                CCTexture2D *texture = self.asset.textureAtlas.textures[[element.atlasIdx integerValue]];
                spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:element.bounds];
            }
            else
            {
//                CCLOGWARN(@"Cannot add sub object with Id: %@, atlas with idx: %u not found.", atlasElementId, element.atlasIdx);
                
            }
        }
        // or in external texture atlas
        else if (self.externalTextureAtlases.count > 0)
        {
            GAFTextureAtlas *externalAtlas = nil;
            for (externalAtlas in [self.externalTextureAtlases allValues])
            {
                element = externalAtlas.elements[atlasElementIdRef];
                if (element != nil)
                {
                    break;
                }
            }
            
            if (nil != element)
            {
                if ([externalAtlas.textures count] > [element.atlasIdx integerValue])
                {
                    CCTexture2D *texture = externalAtlas.textures[[element.atlasIdx integerValue]];
                    spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:element.bounds];
                }
                else
                {
//                    CCLOGWARN(@"Cannot add sub object with Id: %@, atlas with idx: %u not found.", atlasElementId, element.atlasIdx);
                }
            }
        }
        
        if (nil != spriteFrame)
        {
            GAFSpriteWithAlpha* sprite = [[GAFSpriteWithAlpha alloc] initWithSpriteFrame:spriteFrame];
            sprite.objectIdRef = objectIdRef;
            sprite.atlasElementIdRef = atlasElementIdRef;
            
            sprite.visible = NO;
            
            sprite.anchorPoint = CGPointMake(element.pivotPoint.x / sprite.contentSize.width,
                                             1 - (element.pivotPoint.y / sprite.contentSize.height));
            sprite.useExternalTransform = YES;
            
            if (element.scale != 1.0f)
			{
				sprite.atlasScale = 1.0f / element.scale;
			}
            
            sprite.blendFunc = (ccBlendFunc){ GL_ONE, GL_ONE_MINUS_SRC_ALPHA };
            
            (self.subObjects)[objectIdRef] = sprite;
        }
        else
        {
//            CCLOGWARN(@"Cannot add subnode with AtlasElementName: %@, not found in atlas(es). Ignoring.", atlasElementId);
        }
    }
    
    // Adding masks
    for (NSNumber* maskIdRef in [anAnimationMasks allKeys])
    {
        NSNumber* atlasElementIdRef = anAnimationMasks[maskIdRef];
        CCSpriteFrame *spriteFrame = nil;
        
        GAFTextureAtlasElement *element = (self.asset.textureAtlas.elements)[atlasElementIdRef];
        
        if (nil != element)
        {
            if ([self.asset.textureAtlas.textures count] > [element.atlasIdx integerValue])
            {
                CCTexture2D *texture = self.asset.textureAtlas.textures[[element.atlasIdx integerValue]];
                spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:element.bounds];
            }
            else
            {
//                CCLOGWARN(@"Cannot add sub object with Id: %@, atlas with idx: %u not found.", atlasElementId, element.atlasIdx);
            }
        }
        else if (self.externalTextureAtlases.count > 0)
        {
            // Search external atlases for such object
            GAFTextureAtlas *externalAtlas = nil;
            for (externalAtlas in [self.externalTextureAtlases allValues])
            {
                element = externalAtlas.elements[atlasElementIdRef];
                
                if (element != nil)
                {
                    break;
                }
            }
            
            if (nil != element)
            {
                if ([externalAtlas.textures count] > [element.atlasIdx integerValue])
                {
                    CCTexture2D *texture = externalAtlas.textures[[element.atlasIdx integerValue]];
                    spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:element.bounds];
                }
                else
                {
//                    CCLOGWARN(@"Cannot add sub object with Id: %@, atlas with idx: %u not found.", atlasElementId, element.atlasIdx);
                }
            }
        }
		else
		{
			//CCLOGWARN(@"Can not get atlasElementId for key %@. Animation can not work as expected.", maskIdRef);
		}
        
        if (spriteFrame != nil)
        {
            GAFStencilMaskSprite *mask = [[GAFStencilMaskSprite alloc] initWithSpriteFrame:spriteFrame];
            
            mask.objectIdRef = maskIdRef;
            mask.atlasElementIdRef = atlasElementIdRef;
            mask.anchorPoint = CGPointMake(element.pivotPoint.x / mask.contentSize.width,
                                           1 - (element.pivotPoint.y / mask.contentSize.height));
            mask.useExternalTransform = YES;
            
            // Add to masks
            (self.masks)[maskIdRef] = mask;
            //[self addChild:mask];
        }
    }
}

- (void)removeAllSubObjects
{
    [self.subObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        ((GAFSprite *)obj).visible = NO;
        [obj removeFromParentAndCleanup:YES];
    }];
    
    [self.subObjects removeAllObjects];
}

- (GAFSprite *)subobjectByName:(NSString *)aName
{
	if (aName == nil)
	{
		return nil;
	}
	
	NSString *rawName = [self objectIdByObjectName:aName];
	return (rawName != nil) ? [self subobjectByRawName:rawName] : nil;
}

- (NSString *)nameOfSubobject:(GAFSprite *)aSubobject
{
    if (aSubobject == nil)
	{
		return nil;
	}
    NSString *name = nil;
    NSString *rawName = [[self.subObjects allKeysForObject:aSubobject] firstObject];
    if (rawName)
    {
        name = [self.asset.objects objectForKey:rawName];
    }
    if (name == nil)
    {
        name = [self.asset.masks objectForKey:rawName];
    }
    
    return name;
}

- (GAFSprite *)subobjectByRawName:(NSString *)aRawName
{
	return (GAFSprite *)(self.subObjects)[aRawName];
}

- (BOOL)isSubobjectHiddenWithName:(NSString *)aName
{
	NSString *rawName = [self objectIdByObjectName:aName];
    return [self.hiddenSubobjectIds containsObject:rawName];
}

- (void)setSubobjectHidden:(BOOL)isHidden withName:(NSString *)aName
{
	NSString *rawName = [self objectIdByObjectName:aName];
    BOOL alreadyHidden = [self.hiddenSubobjectIds containsObject:rawName];
    if (rawName && isHidden != alreadyHidden)
    {
        if (isHidden)
        {
            [self.hiddenSubobjectIds addObject:rawName];
            
            // Hide subobject if exists
            CCNode *subObject = self.subObjects[rawName];
            if (subObject != nil)
            {
                subObject.visible = NO;
            }
        }
        else
        {
            [self.hiddenSubobjectIds removeObject:rawName];
            [self processCurrentAnimationFrameOnceMore];
        }
    }
}

#pragma mark -

- (void)linkExternalAtlas:(GAFTextureAtlas *)aTextureAtlas forName:(NSString *)anAtlasName
{
    NSParameterAssert(anAtlasName != nil);
    if (anAtlasName == nil)
        return;
    
    [self removeLinkedAtlasForName:anAtlasName];
    
    // Add new atlas to animation
    if (aTextureAtlas != nil && self.externalTextureAtlases[anAtlasName] == nil)
    {
        // To save memory
        [aTextureAtlas releaseImages];
        
        self.externalTextureAtlases[anAtlasName] = aTextureAtlas;
        
        if (self.isInitialized)
        {
            // Get object (and mask) ids to recreate
            NSMutableDictionary *newObjects = [NSMutableDictionary dictionary];
            NSMutableDictionary *newMasks = [NSMutableDictionary dictionary];
            
            for (NSString *namedObjectId in aTextureAtlas.elements)
            {
                NSString *objectOrMaskID = [self objectIdByObjectName:namedObjectId];
                
                id object = self.asset.objects[objectOrMaskID];
                if (object != nil)
                {
                    newObjects[objectOrMaskID] = object;
                }
                else
                {
                    id mask = self.asset.masks[objectOrMaskID];
                    if (mask != nil)
                    {
                        newMasks[objectOrMaskID] = mask;
                    }
                }
            }
            
            // Adding new subobjects
            [self instantiateObject:newObjects animationMasksDictionary:newMasks];
            [self processCurrentAnimationFrameOnceMore];
        }
    }
}


- (void)removeLinkedAtlasForName:(NSString *)anAtlasName
{
    NSParameterAssert(anAtlasName != nil);
    if (anAtlasName == nil)
        return;
    
    // Remove old atlas from animation
    GAFTextureAtlas *oldAtlas = self.externalTextureAtlases[anAtlasName];
    if (oldAtlas != nil)
    {
        if (self.isInitialized)
        {
            // Remove all subobjects that were using old atlas
            NSMutableArray *spriteIdsToRemove = [NSMutableArray new];
            for (GAFSpriteWithAlpha *subObject in [self.subObjects allValues])
            {
                GAFTextureAtlasElement *element = oldAtlas.elements[subObject.atlasElementId];
                if (element != nil)
                {
                    [spriteIdsToRemove addObject:subObject.objectId];
                    
                    // Check if subobject isn't part of mask
                    if (subObject.parent != nil)
                    {
                        [self removeChild:subObject cleanup:YES];
                    }
                    else
                    {
                        GAFStencilMaskSprite *mask = [subObject maskContainer];
                        if (mask != nil)
                        {
                            [mask removeMaskedObject:subObject];
                        }
                    }
                }
            }
            for (NSString *subObjectId in spriteIdsToRemove)
            {
                [self.subObjects removeObjectForKey:subObjectId];
            }
            
            // Remove all masks that were using old atlas
            NSMutableArray *maskIdsToRemove = [NSMutableArray new];
            for (GAFStencilMaskSprite *mask in [self.masks allValues])
            {
                GAFTextureAtlasElement *element = oldAtlas.elements[mask.atlasElementId];
                if (element != nil)
                {
                    [maskIdsToRemove addObject:mask.objectId];
                    [self removeChild:mask cleanup:YES];
                    
                    [mask removeAllMaskedObjects];
                }
            }
            for (NSString *maskId in maskIdsToRemove)
            {
                [self.masks removeObjectForKey:maskId];
            }
        }
        
        [self.externalTextureAtlases removeObjectForKey:anAtlasName];
    }
}

- (BOOL)captureControlOverSubobjectNamed:(NSString *)aName controlFlags:(GAFAnimatedObjectControlFlags)aControlFlags
{
    NSString *objectId = [self objectIdByObjectName:aName];
    if (objectId == nil)
        return NO;
    
    if ((self.capturedObjects)[objectId] != nil)
        return NO;
    
    self.capturedObjects[objectId] = @(aControlFlags);
    
    return YES;
}

- (void)releaseControlOverSubobjectNamed:(NSString *)aName
{
    NSString *objectId = [self objectIdByObjectName:aName];
    if (objectId != nil)
    {
        [self.capturedObjects removeObjectForKey:objectId];
    }
}

#pragma mark -

- (BOOL)isDone
{
    if (self.isLooped)
    {
        return NO;
    }
    else
    {
        if (!_isReversed)
        {
            return self.currentFrameIndex > self.totalFrameCount;
        }
        else
        {
            return self.currentFrameIndex < GAF_FIRST_FRAME_INDEX - 1;
        }
    }
}

-(void)start
{
    [self start:NO];
}

- (void)start:(BOOL)isReversed
{
    if (!self.isInitialized)
    {
        [self initialize];
    }
    
    [self setIsReversed:isReversed];
    
    if (!_animationsSelectorScheduled)
    {
        [self schedule:@selector(processAnimations:)];
        _animationsSelectorScheduled = YES;
    }
    
    if(!self.isReversed)
        [self rewind:RW_BEGIN];
    else
        [self rewind:RW_END];
    self.isRunning = YES;
    
    [self step];
}

- (void)pause
{
    if (self.isRunning)
    {
        self.isRunning = NO;
    }
}

- (void)resume
{
    if (!_animationsSelectorScheduled)
    {
        [self schedule:@selector(processAnimations:)];
        _animationsSelectorScheduled = YES;
    }
    
    if (!self.isRunning)
    {
        self.isRunning = YES;
    }
}

- (void)stop
{
    if (self.isRunning)
    {
        self.currentFrameIndex = GAF_FIRST_FRAME_INDEX;
        self.isRunning = NO;
    }
	[self unschedule:@selector(processAnimations:)];
	_animationsSelectorScheduled = NO;
}

- (void)rewind:(RewindType)rwt
{
    if (rwt == RW_END)
    {
        [self setFrame:self.currentSequenceEnd - 1];
    }
    else if (rwt == RW_BEGIN)
    {
        [self setFrame:self.currentSequenceStart];
    }
}

- (BOOL)setFrame:(NSUInteger)aFrameIndex
{
    if (!self.isInitialized)
    {
        [self initialize];
    }
    
    if (aFrameIndex < self.totalFrameCount)
    {
        self.currentFrameIndex = aFrameIndex;
        [self processAnimation];
		return YES;
    }
	return NO;
}

- (BOOL)gotoSequenceWithNameAndStop:(NSString *)aSequenceName
{
	NSUInteger f = [self startFrameForSequenceWithName:aSequenceName];
	return (f != NSNotFound) ? [self gotoFrameAndStop:f] : NO;
}

- (BOOL)gotoSequenceWithNameAndPlay:(NSString *)aSequenceName looped:(BOOL)isLooped
{
	NSUInteger f = [self startFrameForSequenceWithName:aSequenceName];
	if (f != NSNotFound)
    {
        self.isLooped = isLooped;
        [self gotoFrameAndPlay:f];
    }
    return NO;
}

- (BOOL)gotoFrameAndStop:(NSUInteger)aFrameNumber
{
	if ([self setFrame:aFrameNumber])
	{
		self.isRunning = NO;
		return YES;
	}
	return NO;
}

- (BOOL)gotoFrameAndPlay:(NSUInteger)aFrameNumber
{
	if ([self setFrame:aFrameNumber])
	{
		self.isRunning = YES;
		return YES;
	}
	return NO;
}

- (NSUInteger)startFrameForSequenceWithName:(NSString *)aSequenceName
{
	if (self.asset == nil)
	{
		return NSNotFound;
	}
	GAFAnimationSequence *seq = [self.asset animationSequenceForName:aSequenceName];
	return (seq != nil) ? seq.frameStart: NSNotFound;
}

- (NSUInteger)endFrameForSequenceWithName:(NSString *)aSequenceName
{
	if (self.asset == nil)
	{
		return NSNotFound;
	}
	GAFAnimationSequence *seq = [self.asset animationSequenceForName:aSequenceName];
	return (seq != nil) ? seq.frameEnd : NSNotFound;
}

- (BOOL)playSequenceWithName:(NSString *)aSeqName
                      looped:(BOOL)isLooped
                      resume:(BOOL)aResume
                        hint:(AnimSetSequenceHint)aHint;
{
	if (self.asset == nil)
	{
		return NO;
	}
	
	if (aSeqName == nil || [aSeqName length] == 0)
	{
		return NO;
	}
	NSUInteger s = [self startFrameForSequenceWithName:aSeqName];
	NSUInteger e = [self endFrameForSequenceWithName:aSeqName];
	
	if (s == NSNotFound || e == NSNotFound)
	{
		return NO;
	}
	self.currentSequenceStart = s;
	self.currentSequenceEnd = e;
	
	if (self.currentFrameIndex < self.currentSequenceStart ||
        self.currentFrameIndex > self.currentSequenceEnd)
	{
        [self setFrame:self.currentSequenceStart];
	}
	else
	{
		if (aHint == ASSH_RESTART)
		{
            [self setFrame:self.currentSequenceStart];
		}
		else
		{
			// new hints may appear
		}
	}
	self.isLooped = isLooped;
	if (aResume)
	{
		[self resume];
	}
	else
	{
		[self stop];
	}
    
	return YES;
}

- (BOOL)playSequenceWithName:(NSString *)aSeqName looped:(BOOL)isLooped resume:(BOOL)aResume
{
	return [self playSequenceWithName:aSeqName looped:isLooped resume:aResume hint:ASSH_RESTART];
}

- (BOOL)playSequenceWithName:(NSString *)aSeqName looped:(BOOL)isLooped
{
	return [self playSequenceWithName:aSeqName looped:isLooped resume:YES hint:ASSH_RESTART];
}

- (BOOL)playSequenceWithName:(NSString *)aSeqName
{
	return [self playSequenceWithName:aSeqName looped:NO];
}

- (void)clearSequence
{
	self.currentSequenceStart = GAF_FIRST_FRAME_INDEX;
	self.currentSequenceEnd = self.totalFrameCount;
}

#pragma mark -
#pragma mark Private methods

- (void)initialize
{
    if (!self.isInitialized)
    {
        [self instantiateObject:self.asset.animationObjects animationMasksDictionary:self.asset.animationMasks];
        
        self.isInitialized = YES;
        
        self.currentFrameIndex = GAF_FIRST_FRAME_INDEX;
        
        self.isReversed = NO;
    }
}

- (GAFSprite *)subObjectForInnerObjectId:(NSString *)anInnerObjectId
{
    NSSet *keys = [self.subObjects keysOfEntriesPassingTest:^BOOL (id key, id obj, BOOL *stop)
                   {
                       return (*stop = [((GAFSprite *) obj).objectId isEqual:anInnerObjectId]);
                   }];
    
    if (keys != nil && [keys count] > 0)
    {
        return (self.subObjects)[[keys anyObject]];
    }
    return nil;
}

- (NSString *)objectIdByObjectName:(NSString *)aName
{
    if (aName == nil)
	{
		return nil;
	}
    
    __block NSString *result = nil;
    
    [self.asset.objects enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop)
    {
         if ([(NSString *)obj isEqual:aName])
         {
             result = (NSString *)key;
             *stop = YES;
         }
    }];
    
    if (result == nil)
    {
        [self.asset.masks enumerateKeysAndObjectsUsingBlock:
         ^(id key, id obj, BOOL *stop)
         {
             if ([(NSString *)obj isEqual:aName])
             {
                 result = (NSString *)key;
                 *stop = YES;
             }
         }];
    }
    
	return result;
}

- (NSInteger)numberOfGlobalFramesForOneAnimationFrame
{
    CGFloat globalFPS = roundf(1.0 / [[CCDirector sharedDirector] animationInterval]);
    
    if (globalFPS > (CGFloat)self.FPSType - FLT_EPSILON)
    {
        return (NSInteger)roundf(globalFPS / (CGFloat)self.FPSType);
    }
    else
    {
        return 1;
    }
}

- (void)processAnimations:(ccTime)dt
{
    if (++self.extraFramesCounter >= [self numberOfGlobalFramesForOneAnimationFrame])
    {
        self.extraFramesCounter = 0;
		if (!self.isDone && self.isRunning)
		{
			[self step];
			
			if (framePlayedDelegate != nil)
			{
				[framePlayedDelegate onFramePlayed:self didPlayFrameNo:[self currentFrameIndex]];
			}
		}
    }
}

- (void)step
{
    if(!self.isReversed)
    {
        if (self.currentFrameIndex < self.currentSequenceStart)
        {
            self.currentFrameIndex = self.currentSequenceStart;
        }
        
        if (self.currentFrameIndex >= self.currentSequenceEnd)
        {
            if (self.isLooped)
            {
                self.currentFrameIndex = self.currentSequenceStart;
            }
            else
            {
                self.isRunning = NO;
                return;
            }
        }
    
        [self processAnimation];
    
        if (self.sequenceDelegate != nil && self.asset != nil)
        {
            GAFAnimationSequence *seq = [asset animationSequenceByLastFrame:self.currentFrameIndex];
            if (seq != nil)
            {
                [self.sequenceDelegate onFinishSequence:self sequenceName:seq.name];
            }
        }
    
        ++self.currentFrameIndex;
    }
    else
    {
        // If switched to reverse after final frame played
        if (self.currentFrameIndex >= self.currentSequenceEnd)
        {
            self.currentFrameIndex = self.currentSequenceEnd - 1;
        }
        
        if (self.currentFrameIndex < self.currentSequenceStart)
        {
            if (self.isLooped)
            {
                self.currentFrameIndex = self.currentSequenceEnd - 1;
            }
            else
            {
                self.isRunning = NO;
                return;
            }
            
        }

        [self processAnimation];
        
        
        if (self.sequenceDelegate != nil && self.asset != nil)
        {
            GAFAnimationSequence *seq = [asset animationSequenceByFirstFrame:self.currentFrameIndex + 1];
            if (seq != nil)
            {
                [self.sequenceDelegate onFinishSequence:self sequenceName:seq.name];
            }
        }
        --self.currentFrameIndex;
    }
}

- (void)processCurrentAnimationFrameOnceMore
{
    // Make one processAnimation to restore old objects state (frameIndex is increased in the end
    // of [self step] so we decrease it and restore)
    NSUInteger oldFrameIndex = self.currentFrameIndex;
    if (self.currentFrameIndex != 0)
    {
        --self.currentFrameIndex;
    }
    
    [self processAnimation];
    
    self.currentFrameIndex = oldFrameIndex;
}

- (void)processAnimation
{
    GAFAnimationFrame *currentFrame = (self.asset.animationFrames)[self.currentFrameIndex];
    
    // Make all object invisible
    [self.subObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        ((GAFSprite *)obj).visible = NO;
    }];
    
    // Set states for objects and make mentioned objects visible
    BOOL zOrderChanged = NO;
    for (NSUInteger i = 0; i < currentFrame.objectsStates.count; ++i)
    {
        GAFSubobjectState *state = (currentFrame.objectsStates)[i];
        GAFSpriteWithAlpha *subObject = (self.subObjects)[state.objectIdRef];
        CGAffineTransform stateTransform = state.affineTransform;
        stateTransform.ty -= self.contentSize.height; //flash position to cocos2d position
        stateTransform.tx *= self.asset.usedAtlasContentScaleFactor;
        stateTransform.ty *= self.asset.usedAtlasContentScaleFactor;
        
        if (subObject != nil)
        {
            // Validate sprite type (w/ or w/o filter)
            //GAFBlurFilterData *blurFilter = (state.filters)[kGAFBlurFilterName];
            
            id<GAFFilterData> filter = nil;
            
            if (state.filtersList.count > 0)
            {
                filter = state.filtersList[0];
                [filter apply:subObject];
            }
            
            CGPoint prevAP = subObject.anchorPoint;
            CGSize prevCS = subObject.contentSize;
            
            if (filter == nil || filter.type != GFT_ColorMatrix)
            {
                [subObject setColorMatrixFilterData:nil];
            }
            
            if (filter == nil || filter.type != GFT_Blur)
            {
                [subObject setBlurFiterData:nil];
            }
            
            if (filter == nil || filter.type != GFT_Glow)
            {
                [subObject setGlowFilterData:nil];
            }
            
            if (filter == nil || filter.type != GFT_DropShadow)
            {
                [GAFDropShadowFilterData reset:subObject];
            }
            
            // Handle initial object in one position
            CGSize newCS = subObject.contentSize;
            CGPoint newAP = CGPointMake( ((prevAP.x - 0.5) * prevCS.width) / newCS.width + 0.5,
                                        ((prevAP.y - 0.5) * prevCS.height) / newCS.height + 0.5);
            subObject.anchorPoint = newAP;
            
            // Determine if object is masked or not
            // Depending on that: add to hierarchy OR add to mask
            if (state.maskObjectIdRef == nil)
            {
                if (subObject.parent == nil)
                {
                    [self addChild:subObject];
                }
            }
            else
            {
                if (subObject.parent != nil)
                {
                    [self removeChild:subObject cleanup:NO];
                }
                GAFStencilMaskSprite *mask = self.masks[state.maskObjectIdRef];
                if (mask != nil)
                {
                    [mask addMaskedObject:subObject];
                    
                    if (mask.parent != self)
                    {
                        [self addChild:mask];
                    }
                }
            }
            
            // Determine is subobject is captured
            BOOL subobjectCaptured = NO;
            GAFAnimatedObjectControlFlags controlFlags = kGAFAnimatedObjectControl_None;
            NSNumber *flagsNum = self.capturedObjects[state.objectIdRef];
            if (flagsNum)
            {
                subobjectCaptured = YES;
                controlFlags = [flagsNum unsignedIntegerValue];
            }
            
            if (!subobjectCaptured ||
                (subobjectCaptured && (controlFlags & kGAFAnimatedObjectControl_ApplyState)))
            {
                // Update object position and alpha
                // Applying csf adjustments
                
                
                subObject.externalTransform = GAF_CGAffineTransformCocosFormatFromFlashFormat(stateTransform);
                if (subObject.zOrder != state.zIndex)
                {
                    zOrderChanged |= YES;
                    subObject.zOrder = state.zIndex;
                    
                    if (subObject.maskContainer != nil)
                    {
                        [subObject.maskContainer invalidateMaskedObjectsOrder];
                    }
                }
                
                BOOL forceHide = [self.hiddenSubobjectIds containsObject:subObject.objectId];
                
                subObject.visible = !forceHide && [state isVisible];
                [subObject setColorTransformMult:[state colorMults] offsets:[state colorOffsets]];
            }
        }
        else
        {
            GAFSprite *mask = (self.masks)[state.objectIdRef];
            if (mask != nil)
            {
                mask.externalTransform = GAF_CGAffineTransformCocosFormatFromFlashFormat(stateTransform);
                
                if (mask.zOrder != state.zIndex)
                {
                    zOrderChanged |= YES;
                    mask.zOrder = state.zIndex;
                    
                    if (subObject.maskContainer != nil)
                    {
                        [subObject.maskContainer invalidateMaskedObjectsOrder];
                    }
                }
            }
        }
    }
    
    // Notify control delegate about captured subobjects
    for (GAFSubobjectState *state in currentFrame.objectsStates)
    {
        GAFSpriteWithAlpha *subObject = (self.subObjects)[state.objectIdRef];
        if (subObject != nil)
        {
            // Determine is subobject is captured
            BOOL subobjectCaptured = (self.capturedObjects[state.objectIdRef] != nil);
            
            // If captured, notify delegate about new frame rendering
            if (subobjectCaptured && self.controlDelegate != nil)
            {
                [self.controlDelegate animatedObject:self didDisplayFrameWithSubobject:subObject];
            }
        }
        else
        {
            // Masks cannot be captured right now
        }
    }
}

@end
