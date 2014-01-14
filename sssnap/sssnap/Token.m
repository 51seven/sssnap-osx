//
//  Token.m
//  sssnap
//
//  Created by Christian Poplawski on 14.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "Token.h"
#import "sendPost.h"

@implementation Token

-(NSString *)writeToken:(NSString *)username and: (NSString *) token {
    
    NSString *sssnap = @"/sssnap/token.txt";
    NSString *path = [NSHomeDirectory() stringByAppendingString:sssnap];
    
    NSString *content = [username stringByAppendingString:token];
    NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:fileContents
                                          attributes:nil];
    return path;
    
}

-(NSString *)setToken:(NSString *)username and:(NSString *)password{
    
    sendPost *token = [[sendPost alloc]init];
    NSString *userToken = [token authenticate:username with:password];
    
    return userToken;
    
}


@end
