//
//  sendPost.m
//  sssnap
//
//  Created by Sven Schiffer on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "sendPost.h"
#import <AppKit/AppKit.h>
#import <OAuth2Client/NXOAuth2.h>

@implementation sendPost

// Uploads an Image to the Server
- (void)uploadImage:(NSImage *) image {
    
    // Check if we're connected to the internet
    if([[Reachability reachabilityForInternetConnection] isReachable]) {
        
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData: imageData];
        imageData = [imageRep representationUsingType:NSPNGFileType properties: nil];
        
        NSDictionary *parameters = @{
                                     @"file": imageData,
                                     };
        
        NXOAuth2Account *anAccount = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject];
        if(anAccount) {
            NSLog(@"Using Account: %@", anAccount);
        
            [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                                     secret:@"testsecret"
                                           authorizationURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                                   tokenURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                                redirectURL:[NSURL URLWithString:@"http://51seven.de:8888/"]
                                             forAccountType:@"password"];
        
            [NXOAuth2Request performMethod:@"POST"
                                onResource:[NSURL URLWithString: @"http://51seven.de:8888/api/upload"]
                           usingParameters:parameters
                               withAccount:anAccount
                       sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                       
                           // Getting Progress in Percent
                           int percent = (int) (((float) bytesSend / (float)bytesTotal) * 100);
                           int step = (percent%10==0) ? percent : percent+10-(percent%10);
                       
                           [((AppDelegate *)[[NSApplication sharedApplication] delegate]) changeStatusBarIcon: step];
                       
                           //NSLog(@"Bytes send %lld of total %lld (%i%%)", bytesSend, bytesTotal, step);
                       }
                       responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                           NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                           
                           if(error) {
                               NSLog(@"An error occured: %@", error);
                           }
                           else {
                               NSLog(@"ResponseData: %@", responseString);

                               NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
                               
                               if([userPreferences boolForKey: @"showDesktopNotifications"]) {
                                   [functions sendGrowl: responseString];
                               }
                               if([userPreferences boolForKey: @"copyLinkToClipboard"]) {
                                   [functions copyToClipboard: responseString];
                               }
                           }
                           
                           [((AppDelegate *)[[NSApplication sharedApplication] delegate]) resetStatusBarIcon];
                       }];
        }
        else {
            NSLog(@"User is not logged in");
        }
    }
    else {
        NSLog(@"ImageUpload has been canceled because of missing internet connection.");
        // ToDo: Implement Userfeedback
    }
}

// Uploads an Image to the Server
- (void)getRecentSnaps {
    
    // Check if we're connected to the internet
    if([[Reachability reachabilityForInternetConnection] isReachable]) {
        
        NSDictionary *parameters = @{
                                     @"file": @"test",
                                     };
        
        NXOAuth2Account *anAccount = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject];
        
        if(anAccount) {
            NSLog(@"Using Account: %@", anAccount);
            
            [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                                     secret:@"testsecret"
                                           authorizationURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                                   tokenURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                                redirectURL:[NSURL URLWithString:@"http://51seven.de:8888/"]
                                             forAccountType:@"password"];
            
            [NXOAuth2Request performMethod:@"POST"
                                onResource:[NSURL URLWithString: @"http://51seven.de:8888/api/list/3"]
                           usingParameters:nil
                               withAccount:anAccount
                       sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) { }
                           responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                               NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                               
                               if(error) {
                                   NSLog(@"An error occured: %@", error);
                               }
                               else {
                                   NSLog(@"Response was successfull.");
                                   NSLog(@"ResponseData: %@", responseString);
                               }
                           }];
        }
        else {
            NSLog(@"User is not logged in");
        }
    }
    else {
        NSLog(@"Cant access your recent Snaps, because you have no internet connection.");
        // ToDo: Implement Userfeedback
    }
}



@end
