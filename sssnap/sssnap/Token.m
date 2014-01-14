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
    
-(id) init {
    
    tokenPath = @"x";
    tokenExists = false;
    
    return self;
}

//
//  Writes token and Username to a file called token.txt
//  Directory: /users/USER/sssnap/token.txt
//  Format in token.txt: username:token
//
-(NSString *)writeToken:(NSString *)username and: (NSString *) token {
    
    NSLog(@"DEBUG: empty tokenPath is %@", tokenPath);
    
    //  Build path
    NSString *sssnap = @"/sssnap/token.txt";
    NSString *path = [NSHomeDirectory() stringByAppendingString:sssnap];
    
    //  Check if directory already exists
    NSString *pathToFile = [NSHomeDirectory() stringByAppendingString:@"/sssnap"];
    BOOL isDir = NO;
    BOOL isFile = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile isDirectory:&isDir];
    
    if(isFile)
    {
        NSLog(@"Directory exists");
    }
    else
    {
        [ [ NSFileManager defaultManager ] createDirectoryAtPath: pathToFile withIntermediateDirectories: YES attributes: nil error: NULL ];
        NSLog(@"Directory does not exist, created one");
    }
    
    
    //  Write username and token to file
    NSString *aToken = [@":" stringByAppendingString:token];
    NSString *content = [username stringByAppendingString:aToken];
    NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:fileContents
                                          attributes:nil];
    //save path and return it
    tokenExists = true;
    tokenPath = path;
    return path;
    
}


//
//  Gets a new Token from the server
//
-(NSString *)setToken:(NSString *)username and:(NSString *)password{
    
    sendPost *token = [[sendPost alloc]init];
    NSString *userToken = [token authenticate:username with:password];
    
    return userToken;
    
}

//
//  Read the saved Token and return it
//
-(NSString *)readTokenFile {
    
    if(tokenExists == true){
        NSLog(@"There is a token at %@", tokenPath);
        
        //read file contents
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfFile:tokenPath encoding:NSUTF8StringEncoding error:&error];
        
        NSLog(@"Read from file : %@", fileContents);
            }
    else {
        NSLog(@"There is no token to be read");

    }
    return NULL;
}


@end
