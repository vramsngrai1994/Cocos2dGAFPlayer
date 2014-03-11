////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFSubobjectState.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GAFAsset.h"
#import "GAFSubobjectState.h"
#import "GAFFilterData.h"
#import "ccMacros.h"

@implementation GAFSubobjectState

#pragma mark -
#pragma mark Properties

@synthesize objectIdRef;
@synthesize zIndex;
@synthesize maskObjectIdRef;
@synthesize atlasElementName;
@synthesize affineTransform;
@synthesize filters;

#pragma mark -
#pragma mark Initialization & Release

- (id) initEmpty:(NSNumber *)anObjectIdRef
{
    self = [super init];
    
    if (nil != self)
    {
        self.objectIdRef = anObjectIdRef;
        self.maskObjectIdRef = nil;
        self.zIndex = 0;
        self.affineTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        _colorOffsets[0] = _colorOffsets[1] = _colorOffsets[2] = _colorOffsets[3] = _colorMults[GAFCTI_A] = 0;
		_colorMults[GAFCTI_R]   = _colorMults[GAFCTI_G]   = _colorMults[GAFCTI_B] = 1;
    }
    
    return self;
}
#pragma mark -
#pragma mark Overriden methods

- (id)copyWithZone:(NSZone *)zone
{
    GAFSubobjectState *newState = [[GAFSubobjectState allocWithZone:zone] init];
    newState.objectIdRef = self.objectIdRef;
    newState.zIndex = self.zIndex;
    newState.maskObjectIdRef = self.maskObjectIdRef;
    newState.atlasElementName = self.atlasElementName;
    newState.affineTransform = self.affineTransform;
    newState.filters = [self.filters copyWithZone:zone];
    return newState;
}

- (BOOL)isEqual:(id)object
{
    if (object == nil || ![object isKindOfClass:[self class]])
        return NO;
    if (object == self)
        return YES;
    
    GAFSubobjectState *state = (GAFSubobjectState *)object;
    
    return ([state.objectIdRef isEqualToNumber:self.objectIdRef] &&
            state.zIndex == self.zIndex &&
            [state.maskObjectIdRef isEqualToNumber:self.maskObjectIdRef] &&
            [state.atlasElementName isEqualToString:self.atlasElementName] &&
            CGAffineTransformEqualToTransform(state.affineTransform, self.affineTransform) &&
            [state.filters isEqualToDictionary:self.filters]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"< ID = %d | zIndex = %ld | maskID = %d | atlasElemenName = %@ | transform = (%@) | filters = %@ >",
            [self.objectIdRef integerValue], (long)self.zIndex, [self.maskObjectIdRef integerValue], self.atlasElementName,
            NSStringFromCGAffineTransform(self.affineTransform),
            [self.filters description]];
}

#pragma mark -
#pragma mark Public methods

- (BOOL)isVisible
{
	return _colorMults[GAFCTI_A] != 0.0f;
}

- (GLfloat *)colorMults
{
	return (GLfloat *) &_colorMults[0];
}

- (GLfloat *)colorOffsets
{
	return (GLfloat *) &_colorOffsets[0];
}

- (void)ctxMakeIdentity
{
    _colorOffsets[0] = _colorOffsets[1] = _colorOffsets[2] = _colorOffsets[3] = 0;
    _colorMults[GAFCTI_R] = _colorMults[GAFCTI_G] = _colorMults[GAFCTI_B] = 1;
}

#pragma mark -
#pragma mark Private methods

@end