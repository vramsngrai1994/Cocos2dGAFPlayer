////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFAsset.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@class GAFTextureAtlas;
@class GAFAnimatedObject;
@class GAFAnimationFrame;
@class GAFAnimationSequence;

#import <ccTypes.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//extern NSString * const kGAFAssetRootObjectName;
//extern NSString * const kGAFAssetWindowMaskName;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFAsset : NSObject

#pragma mark Parsed data

@property (nonatomic, assign, readonly) NSUInteger          majorVersion;
@property (nonatomic, assign, readonly) NSUInteger          minorVersion;

@property (nonatomic, strong, readonly) GAFTextureAtlas     *textureAtlas;
@property (nonatomic, assign, readonly) CGFloat             usedAtlasContentScaleFactor; // csf of used atlas

@property (nonatomic, strong, readonly) NSDictionary        *objects; // dictionary of objects [ObjectId -> AtlasElementName]

@property (nonatomic, strong) NSMutableDictionary*          animationObjects; // dictionary of objects [ObjectIdRef -> Element atlas id]
@property (nonatomic, strong) NSMutableDictionary*          animationMasks; // dictionary of objects [ObjectIdRef -> Element atlas id]

@property (nonatomic, strong, readonly) NSDictionary        *masks; // dictionary of masks [MaskId -> AtlasElementName]

/// List of extended data object groups. Key - groupJSONName, Value - group, which is an array of parsed objects.
@property (nonatomic, strong, readonly) NSMutableDictionary *extendedDataObjectGroups;

#pragma mark Animation related data

@property (nonatomic, strong) NSMutableArray*               animationFrames; ///< List of GAFAnimationFrame objects
@property (nonatomic, strong) NSMutableDictionary*          animationSequences; ///< List of GAFAnimationSequences objects

@property (nonatomic, assign) CGRect                        boundingBox;
@property (nonatomic, assign, readonly) CGPoint             pivotPoint;
@property (nonatomic, strong) NSMutableArray*               textureAtlases;
@property (nonatomic, strong) NSMutableDictionary*          namedParts;

@property (nonatomic) NSUInteger                            sceneFps;
@property (nonatomic) NSUInteger                            sceneWidth;
@property (nonatomic) NSUInteger                            sceneHeight;
@property (nonatomic) ccColor4B                             sceneColor;

#pragma mark Methods

+ (BOOL)isAssetVersionPlayable:(NSString *)version;


- (id) initWithGAFFile:(NSString*)aGAFfilePath keepImagesInAtlas:(BOOL)aKeepImagesInAtlas;

- (id) initWithGAFFile:(NSString*)aGAFFilePath
 atlasesDataDictionary:(NSDictionary *)anAtlasesDataDictionary
 orAtlasTexturesFolder:(NSString *)anAtlasTexturesFolder
extendedDataObjectClasses:(NSDictionary *)anExtendedDataObjectClasses
     keepImagesInAtlas:(BOOL)aKeepImagesInAtlas;

- (id) initWithGAFFileData:(NSData*)aGAFFileData
 atlasesDataDictionary:(NSDictionary *)anAtlasesDataDictionary
 orAtlasTexturesFolder:(NSString *)anAtlasTexturesFolder
extendedDataObjectClasses:(NSDictionary *)anExtendedDataObjectClasses
     keepImagesInAtlas:(BOOL)aKeepImagesInAtlas;

/// Returns list of all available sequence names
- (NSArray *)animationSequenceNames;
- (GAFAnimationSequence *)animationSequenceForName:(NSString *)aName;
- (GAFAnimationSequence *)animationSequenceByLastFrame:(NSUInteger)aLastFrame;
- (GAFAnimationSequence *)animationSequenceByFirstFrame:(NSUInteger)aFirstFrame;

@end
