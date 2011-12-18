//
//  main.m
//  RetainCarousel
//
//  Created by Laurin Brandner on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectA.h"
#import "ObjectB.h"

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        ObjectA* a = [ObjectA new];
        ObjectB* b = [ObjectB new];
        
        [b setA:a];
        
        NSLog(@"set value b");
        [a setB:b];
        
        NSLog(@"set value spagett");
        [a setSpagett:b];
        
        [a release];
        [b release];
    }
    return 0;
}

