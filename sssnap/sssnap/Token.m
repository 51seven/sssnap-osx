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
    

    usernameGlobal = @"x";
    tokenGlobal = @"x";
    
    return self;
}

//
//  Check if the sssnap directory already exists.
//  If not, it's the first start of the app, directory will be created.
//
+(void)checkTokenDir {
    
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

    
}



//
//  Checks if the token.txt exists
//  Returns BOOL
//
+(BOOL)tokenFileExists {
    
    BOOL exists;
    
    //Make sure the directroy exists
    [Token checkTokenDir];
    
    //  Check if file exists
    NSString *pathToFile = [NSHomeDirectory() stringByAppendingString:@"/sssnap/token.txt"];
    BOOL isDir = NO;
    BOOL isFile = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile isDirectory:&isDir];
    
    if(isFile)
    {
        NSLog(@"Directory exists");
        return exists = YES;
        
        
    }
    else
    {
        
        NSLog(@"Directory does not exist, created one");
        return exists = NO;
    }

    
}

//
//  Writes token and Username to a file called token.txt
//  Directory: /users/USER/sssnap/token.txt
//  Format in token.txt: username:token
//
-(NSString *)writeToken:(NSString *)username and: (NSString *) token {
    
    NSLog(@"Token to write to File: %@", token);
    
    //  Build path
    NSString *sssnap = @"/sssnap/token.txt";
    NSString *path = [NSHomeDirectory() stringByAppendingString:sssnap];
    
    //Check if directory exists/create one
    [Token checkTokenDir];
    
    //  Write username and token to file
    NSString *aToken = [@":" stringByAppendingString:token];
    NSString *content = [username stringByAppendingString:aToken];
    NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:fileContents
                                          attributes:nil];

    return path;
    
}

-(NSString *)getToken {
    return tokenGlobal;
}

-(NSString *)getUsername {
    return usernameGlobal;
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
-(BOOL)readTokenFile {
    
    
    
    if([Token tokenFileExists]){
        NSString *pathToToken = [Token getTokenPath];
        
        
        //read file contents
        NSError *error;
        NSString *usernameToken = [NSString stringWithContentsOfFile:pathToToken encoding:NSUTF8StringEncoding error:&error];
        
        //Split the String in two strings
        NSArray *usernameTokenArray = [usernameToken componentsSeparatedByCharactersInSet:
                                       [NSCharacterSet characterSetWithCharactersInString:@"-:"]
                                       ];
        
        usernameGlobal = [usernameTokenArray objectAtIndex:0];
        tokenGlobal = [usernameTokenArray objectAtIndex:1];
        NSLog(@"Token read from file: %@",tokenGlobal);
        
        return YES;

    }else {
        return NO;
    }
    

    
    //NSLog(@"username: %@", usernameGlobal);
    //NSLog(@"Token: %@", tokenGlobal);
    
}

+(NSString *)getTokenPath {
    
    //  Build path
    NSString *sssnap = @"/sssnap/token.txt";
    NSString *path = [NSHomeDirectory() stringByAppendingString:sssnap];
    
    return path;
}


@end
