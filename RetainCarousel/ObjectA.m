//
//  ObjectA.m
//  RetainCarousel
//
//  Created by Laurin Brandner on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectA.h"

@implementation ObjectA

@synthesize b, spagett;

-(void)setB:(id)var {
    NSLog(@"setB:");
    if (![var isEqual:b]) {
        [b release];
        b = [var retain];
    }
}

-(void)setSpagett:(id)var {
    NSLog(@"setSpagett:");
    if (![var isEqual:spagett]) {
        [spagett release];
        spagett = [var retain];
    }
}

@end
