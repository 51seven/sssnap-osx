//
//  sendPost.h
//  sssnap
//
//  Created by Sven Schiffer on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "functions.h"
#import "AppDelegate.h"
#import <tgmath.h>
#import "Reachability.h"

@interface sendPost : NSObject

-(void)uploadImage:(NSImage *) image;
-(void)getRecentSnaps;

@end
