//
//  Token.h
//  sssnap
//
//  Created by Christian Poplawski on 14.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token : NSObject{
    NSString *usernameGlobal;
    NSString * tokenGlobal;

}


- (NSString *)setToken:(NSString *)username and: (NSString *) token;
- (NSString *)writeToken:(NSString *)username and: (NSString *) password;
- (NSString *)getUsername;
- (NSString *)getToken;
- (BOOL)readTokenFile;
+ (void)checkTokenDir;
+ (BOOL) tokenFileExists;
+ (NSString *) getTokenPath;

@end
