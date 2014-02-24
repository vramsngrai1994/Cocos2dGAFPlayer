//
//  GAFCustomAtlasPreprocessor.m
//  GAFPlayer
//
//  Created by Sergey Sergeev on 12/13/13.
//  Copyright (c) 2013 CatalystApps. All rights reserved.
//

#import "GAFCustomAtlasPreprocessor.h"
#import "GAFConstants.h"

@interface GAFCustomAtlasChunk : NSObject

@property(nonatomic, assign) CGRect frame;

@end

@implementation GAFCustomAtlasChunk

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        self.frame = frame;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if(!CGRectEqualToRect(_frame, frame))
    {
        _frame = frame;
    }
}

@end

@interface GAFCustomAtlasPreprocessor()

@property(nonatomic, strong) NSMutableArray* chunks;

@end

@implementation GAFCustomAtlasPreprocessor

- (id)init
{
    self = [super init];
    if (self)
    {
        _chunks = [NSMutableArray new];
        [_chunks addObject:[[GAFCustomAtlasChunk alloc] initWithFrame:CGRectMake(0, 0, kGAFgaussianTextureAtlasWidth, kGAFgaussianTextureAtlasHeight)]];
    }
    return self;
}

- (CGRect)frameForTextureWithFrame:(CGRect)sourceFrame;
{
    CGRect resultedFrame = CGRectZero;
    NSArray* appropriateChunks = [self.chunks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        GAFCustomAtlasChunk* chunk = evaluatedObject;
        return sourceFrame.size.width <= chunk.frame.size.width &&
        sourceFrame.size.height <= chunk.frame.size.height? YES : NO;
    }]];
    if([appropriateChunks count] != 0)
    {
        GAFCustomAtlasChunk* chunk = [appropriateChunks objectAtIndex:0];
        CGRect originalFrame = chunk.frame;
        CGRect newFrame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, sourceFrame.size.width, sourceFrame.size.height);
        CGRect originatedFrame[3];
        
        originatedFrame[0] = CGRectMake(newFrame.origin.x + newFrame.size.width,
                                        newFrame.origin.y,
                                        originalFrame.size.width - newFrame.size.width,
                                        newFrame.size.height);
        
        originatedFrame[1] = CGRectMake(newFrame.origin.x,
                                        newFrame.origin.y + newFrame.size.height,
                                        newFrame.size.width,
                                        originalFrame.size.height - newFrame.size.height);
        
        originatedFrame[2] = CGRectMake(newFrame.origin.x + newFrame.size.width,
                                        newFrame.origin.y + newFrame.size.height,
                                        originalFrame.size.width - newFrame.size.width,
                                        originalFrame.size.height - newFrame.size.height);
        [self.chunks removeObject:chunk];
        for(NSInteger index = 0; index < 3; ++index)
        {
            [self.chunks addObject:[[GAFCustomAtlasChunk alloc] initWithFrame:originatedFrame[index]]];
        }
        resultedFrame = newFrame;
    }
    return resultedFrame;
}

@end
