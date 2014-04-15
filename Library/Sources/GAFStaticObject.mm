////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  GAFStaticObject.m
//  GAF Animation Library
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports

#import "GAFStaticObject.h"
#import "GAFNode.h"
#import "GAFSprite.h"
#import "GAFAsset.h"
#import "GAFCommon.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Private interface

@interface GAFStaticObject ()
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation

@implementation GAFStaticObject

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initialization & Release

+ (GAFStaticObject *)staticObjectWithAsset:(GAFAsset *)anAsset
{
    return [[self alloc] initWithAsset:anAsset];
}

+ (GAFStaticObject *)staticObjectWithAsset:(GAFAsset *)anAsset
                             externalAtlas:(GAFTextureAtlas *)anAtlas
                                 atlasName:(NSString *)anExternalAtlasName
{
    return [[self alloc] initWithAsset:anAsset
                         externalAtlas:anAtlas
                             atlasName:anExternalAtlasName];
}

- (id)initWithAsset:(GAFAsset *)anAsset
{
    if ((self = [super initWithAsset:anAsset]))
    {
        [self start];
        [self gotoFrameAndStop:0];
    }
    return self;
}

- (id)initWithAsset:(GAFAsset *)anAsset
      externalAtlas:(GAFTextureAtlas *)anAtlas
          atlasName:(NSString *)anExternalAtlasName
{
    if ((self = [super initWithAsset:anAsset]))
    {
        [self linkExternalAtlas:anAtlas forName:anExternalAtlasName];
        [self start];
        [self gotoFrameAndStop:0];
    }
    return self;
}

#pragma mark -
#pragma mark Public methods

#pragma mark -
#pragma mark Private methods

@end