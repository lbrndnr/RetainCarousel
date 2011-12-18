//
//  NSObject+RetainCarousel.m
//  RetainCarousel
//
//  Created by Laurin Brandner on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RetainCarousel.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"

@implementation NSString (LBAdditions)

-(BOOL)containsSubstring:(NSString *)substring {
    return ([self rangeOfString:substring].location != NSNotFound);
}

-(NSString*)stringByBeginingUppercase {
    return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
}

@end

static inline BOOL property_retains(objc_property_t property) {
    NSString* rawAttributes = [[[NSString alloc] initWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding] autorelease];
    NSArray* attributes = [rawAttributes componentsSeparatedByString:@","];
    
    BOOL retain = NO;
    
    for (NSString* attribute in attributes) {
        if ([attribute isEqualToString:@"&"]) {
            retain = YES;
        }
    }
    
    return retain;
}

static inline BOOL propertyNeedsToGetReplaced(objc_property_t property) {
    if (!property) {
        return NO;
    }
    
    if (property_retains(property)) {
        return YES;
    }
    return NO;
}

@interface NSObject ()

-(void)original_setValue:(id)value;
-(void)setValue:(id)value;
-(objc_property_t)propertyForObject:(id)obj;

@end
@implementation NSObject (RetainCarousel)

+(void)initialize {
    @autoreleasepool {
        unsigned int propertyCount;
        objc_property_t* properties = class_copyPropertyList(self, &propertyCount);
        
        SEL originalNewAccessor = @selector(original_setValue:);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            
            if (!propertyNeedsToGetReplaced(property)) {
                continue;
            }
            
            NSString* ivarName = [[[[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding] autorelease] stringByBeginingUppercase];
            
            SEL oldAccessor = NSSelectorFromString([NSString stringWithFormat:@"set%@:", ivarName]);
            
            SEL newAccessor = NSSelectorFromString([NSString stringWithFormat:@"original_set%@:", ivarName]);
            Method newAccessorMethod = class_getInstanceMethod(self, @selector(setValue:));
            class_addMethod(self, newAccessor, method_getImplementation(newAccessorMethod), method_getTypeEncoding(newAccessorMethod));
            
            [self jr_copyMethodImplemention:originalNewAccessor toMethod:newAccessor error:nil];
            [self jr_swizzleMethod:oldAccessor withMethod:newAccessor error:nil];
        }
    }
}

-(void)original_setValue:(id)value {
    unsigned int ivarCount;
    Ivar* ivars = class_copyIvarList(object_getClass(value), &ivarCount);
    
    for (unsigned int i = 0; i < ivarCount; i++) {
        id possibleSelf = object_getIvar(value, ivars[i]);
        if ([self isEqual:possibleSelf]) {            
            // Check whether value retains self back
            objc_property_t selfProperty = [value propertyForObject:self];
            
            if (property_retains(selfProperty)) {
                NSLog(@"Retain Cycle spotted while retaining %@ by %@", value, self);
            }
        }
    }
    
    SEL originalAccessor = NSSelectorFromString([@"original_" stringByAppendingString:NSStringFromSelector(_cmd)]);
    [self performSelector:originalAccessor withObject:value];
}

-(void)setValue:(id)value {
    
}

-(objc_property_t)propertyForObject:(id)obj {
    unsigned int propertyCount;
    objc_property_t* properties = class_copyPropertyList(object_getClass(self), &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; i++) {
        NSString* name = [[[NSString alloc] initWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] autorelease];
        id var = [self valueForKey:name];
        
        if ([var isEqual:obj]) {
            return properties[i];
        }
    }
    
    return nil;
}

@end