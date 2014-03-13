////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFAnimationSequence.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFAnimationSequence : NSObject

@property (nonatomic, copy  , readonly) NSString *name;
@property (nonatomic, assign, readonly) NSUInteger  frameStart;
@property (nonatomic, assign, readonly) NSUInteger  frameEnd;

- (id)initWithName:(NSString *)aName frameStart:(NSUInteger)aFrameStart frameEnd:(NSUInteger)aFrameEnd;

@end
