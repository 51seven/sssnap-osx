//
//  functions.h
//  sssnap
//
//  Created by Sven Schiffer on 23.5.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface functions : NSObject

- (void)sendGrowl:(NSString *)data;
- (void)copyToClipboard:(NSString *)data;
- (BOOL)dateIsExpired:(NSDate *) date;

@end
