//
//  sendPost.h
//  sssnap
//
//  Created by Sven Schiffer on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "functions.h"
#import <OAuth2Client/NXOAuth2.h>

@interface sendPost : NSObject

//-(NSString *)authenticate:(NSString *) username with:(NSString *) password;
//-(BOOL)isValidToken:(NSString *) username with:(NSString *) token;
-(void)uploadImage:(NSImage *) image;


@end
