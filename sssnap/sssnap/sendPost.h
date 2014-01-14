//
//  sendPost.h
//  sssnap
//
//  Created by Sven Schiffer on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sendPost : NSObject

-(NSString *)authenticate:(NSString *) username with:(NSString *) password;
-(NSString *)uploadImage:(NSImage *) image authWith:(NSString *) username and:(NSString *) usertoken;

@end
