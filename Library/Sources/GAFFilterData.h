////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFFilterData.h
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

extern NSString * const kGAFBlurFilterName;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFFilterData : NSObject

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GAFBlurFilterData : GAFFilterData

@property (nonatomic, assign) CGSize blurSize;

@end