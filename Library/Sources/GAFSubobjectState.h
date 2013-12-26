////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFSubobjectState.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, GAFColorTransformIndex)
{
	GAFCTI_R = 0,
	GAFCTI_G,
	GAFCTI_B,
	GAFCTI_A,
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFSubobjectState : NSObject <NSCopying>
{
	CGFloat _colorMults[4];
	CGFloat _colorOffsets[4];
}
@property (nonatomic,   copy) NSString          *objectId;
@property (nonatomic, assign) NSInteger         zIndex;
@property (nonatomic,   copy) NSString          *maskObjectId;
@property (nonatomic,   copy) NSString          *atlasElementName;
@property (nonatomic, assign) CGAffineTransform affineTransform;
@property (nonatomic, strong) NSDictionary      *filters;

- (id)initEmptyStateWithObjectId:(NSString *)anObjectId;
- (id)initWithStateDictionary:(NSDictionary *)aStateDictionary objectId:(NSString *)anObjectId;

- (BOOL)isVisible;
- (GLfloat *)colorMults;
- (GLfloat *)colorOffsets;

@end
