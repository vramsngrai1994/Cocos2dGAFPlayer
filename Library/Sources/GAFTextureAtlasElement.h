////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFTextureAtlasElement.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFTextureAtlasElement : NSObject

@property (nonatomic,   copy) NSString   *name;
@property (nonatomic, assign) CGPoint    pivotPoint;
@property (nonatomic, assign) CGRect     bounds;
@property (nonatomic, copy)   NSNumber*  atlasIdx;
@property (nonatomic, copy)   NSNumber*  elementAtlasIdx;
@property (nonatomic, assign) CGFloat    scale;

// DI
- (id)init;
- (id)initWithDictionary:(NSDictionary *)aDictionary;

@end
