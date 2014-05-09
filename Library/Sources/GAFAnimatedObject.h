////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFAnimatedObject.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "CCLayer.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class GAFAsset;
@class GAFObjectAnimation;
@class GAFSprite;
@class GAFAnimatedObject;
@class GAFTextureAtlas;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, GAFAnimationFPSType) // Obsolete. Will be removed
{
    kGAFAnimationFPSType_15 = 15,
    kGAFAnimationFPSType_30 = 30,
    kGAFAnimationFPSType_60 = 60
};

typedef NS_ENUM(NSUInteger, AnimSetSequenceHint)
{
	ASSH_CONTINUE = 0,
	ASSH_RESTART
};

typedef NS_ENUM(NSUInteger, RewindType)
{
    RW_END,
    RW_BEGIN
};

typedef NS_ENUM(NSUInteger, GAFAnimatedObjectControlFlags)
{
    kGAFAnimatedObjectControl_None = 0,
    // If specified, state of controlled object will be changed every frame (like it is by default) and then
    // animatedObject:didDisplayFrameWithSubobject: will be called
    kGAFAnimatedObjectControl_ApplyState = 1 << 0
};

#define GAF_FIRST_FRAME_INDEX 0

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol GAFFramePlayedDelegate <NSObject>

@required
- (void)onFramePlayed:(GAFAnimatedObject *)anObject didPlayFrameNo:(NSUInteger)aFrameNo;

@end

@protocol GAFSequenceDelegate <NSObject>

@required
- (void)onFinishSequence:(GAFAnimatedObject *)anObject sequenceName:(NSString *)aSequenceName;

@end

@protocol GAFAnimatedObjectControlDelegate <NSObject>

@required
- (void)animatedObject:(GAFAnimatedObject *)anObject didDisplayFrameWithSubobject:(GAFSprite *)aSubobject;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Graphic object which consists of set of different graphic objects and single texture atlas.
@interface GAFAnimatedObject : CCLayer
{
@private
    BOOL _animationsSelectorScheduled;
}

@property (nonatomic, strong) GAFAsset            *asset;
@property (nonatomic, strong) NSMutableDictionary *subObjects;
@property (nonatomic, strong) NSMutableDictionary *masks; ///< stores all masks (not displayed)
@property (nonatomic, assign) NSInteger           currentFrameIndex;
@property (nonatomic, assign) NSInteger           totalFrameCount;
@property (nonatomic, assign) NSInteger           currentSequenceStart;
@property (nonatomic, assign) NSInteger           currentSequenceEnd;
@property (nonatomic, assign) GAFAnimationFPSType FPSType; // Obsolete. Will be removed
@property (nonatomic, assign) NSInteger           Fps;
@property (nonatomic, assign) NSUInteger          extraFramesCounter;
@property (nonatomic, strong) NSMutableDictionary *externalTextureAtlases; ///< Value is of GAFTextureAtlas class
@property (nonatomic, strong) NSMutableArray      *hiddenSubobjectIds;

@property (nonatomic, assign, readonly) BOOL    isInitialized;
@property (nonatomic, assign, readonly) BOOL    isRunning;
@property (nonatomic, assign          ) BOOL    isLooped;
@property (nonatomic, assign          ) BOOL    isReversed;

// do not forget clear delegates if you use them
@property (nonatomic, assign) id <GAFFramePlayedDelegate          > framePlayedDelegate;
@property (nonatomic, assign) id <GAFSequenceDelegate             > sequenceDelegate;
@property (nonatomic, assign) id <GAFAnimatedObjectControlDelegate> controlDelegate;


+ (id)animatedObjectWithAsset:(GAFAsset *)anAsset;

+ (id)animatedObjectWithPath:(NSString *)aGAFPath;
+ (id)animatedObjectWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped;
+ (id)animatedObjectWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped andRun:(BOOL)run;

/// Designated initializer
- (id)initWithAsset:(GAFAsset *)anAsset;

- (id)initWithPath:(NSString *)aGAFPath;
- (id)initWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped;
- (id)initWithPath:(NSString *)aGAFPath looped:(BOOL)isLooped andRun:(BOOL)run;

#pragma mark Dimensions

/// Merges all visible subobjects rects and returns result
- (CGRect)realBoundingBoxForCurrentFrame;

#pragma mark Working with subobjects and external objects

/// Returns subobject which has specified name assinged to it ("animationObjects" section in config)
- (GAFSprite *)subobjectByName:(NSString *)aName;
/// Returns subobject by raw name (usually "Zn", where n is natural number (1,2,3,...))
- (GAFSprite *)subobjectByRawName:(NSString *)aRawName;

- (NSString *)nameOfSubobject:(GAFSprite *)aSubobject;

/// Hides or show subobject which has specified name assinged to it ("animationObjects" section in config)
- (BOOL)isSubobjectHiddenWithName:(NSString *)aName;
- (void)setSubobjectHidden:(BOOL)isHidden withName:(NSString *)aName;

/// Uses objects from atlas by linking their IDs to IDs specified in 'animationObjects' config section
/// @note after execution of this method, aTextureAtlas will have only textures, images will be released
/// @param aTextureAtlas new texture atlas
/// @param anOldTextureAtlas old external texture atlas that should be replaced by a new one (can be nil)
- (void)linkExternalAtlas:(GAFTextureAtlas *)aTextureAtlas forName:(NSString *)anAtlasName;
- (void)removeLinkedAtlasForName:(NSString *)anAtlasName;

/// Takes control over subobject, which means that every frame control delegate will be notified to decide
/// what to do with captured external object
/// @note it supports only objects for now, DOES NOT SUPPORT MASKS
/// @param subobject name taken from "animationObjects" section in config
/// @param controlFlags flags specifying what played will do with subobjects controlled externally
/// @returns YES if control was successfully taken and all future 
- (BOOL)captureControlOverSubobjectNamed:(NSString *)aName controlFlags:(GAFAnimatedObjectControlFlags)aControlFlags;
/// Releases control over subobject captured earlier
- (void)releaseControlOverSubobjectNamed:(NSString *)aName;

#pragma mark Managing animation playback

/// @returns YES if the animation is finished, otherwise NO
- (BOOL)isDone;

/// Initializes animation for first use, won't run animation
- (void)initialize;

- (void)start:(BOOL)isReversed;
- (void)start;
- (void)pause;
- (void)resume;
/// Stops animation and sets the currentFrame pointer to the first frame
- (void)stop;
/// Sets currentFrame and applies specified frame state to animation objects
- (BOOL)setFrame:(NSUInteger)aFrameIndex;

- (void) rewind:(RewindType) rwt;

/// Plays only first frame of specified animation and then stops
- (BOOL)gotoSequenceWithNameAndStop:(NSString *)aSequenceName;
/// Plays animation with specified name
- (BOOL)gotoSequenceWithNameAndPlay:(NSString *)aSequenceName looped:(BOOL)isLooped;

/// Plays specified frame and then stops
- (BOOL)gotoFrameAndStop:(NSUInteger)aFrameNumber;
/// Plays animation from specified frame
- (BOOL)gotoFrameAndPlay:(NSUInteger)aFrameNumber;

#pragma mark Animation sequences

- (NSUInteger)startFrameForSequenceWithName:(NSString *)aSequenceName;
- (NSUInteger)endFrameForSequenceWithName:(NSString *)aSequenceName;

/// Plays animation sequence with specified name
/// @param aSeqName a sequence name
/// @param isLooped if YES - sequence should play in cycle
/// @param aResume if YES - animation will be played immediately, if NO - playback will be paused after the first frame is shown
/// @param aHint specific animation playback parameters
- (BOOL)playSequenceWithName:(NSString *)aSeqName looped:(BOOL)isLooped resume:(BOOL)aResume hint:(AnimSetSequenceHint)aHint;
- (BOOL)playSequenceWithName:(NSString *)aSeqName looped:(BOOL)isLooped resume:(BOOL)aResume;
- (BOOL)playSequenceWithName:(NSString *)aSeqName looped:(BOOL)isLooped;
- (BOOL)playSequenceWithName:(NSString *)aSeqName;
- (void)clearSequence;

@end