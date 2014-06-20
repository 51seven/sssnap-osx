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
        
        NXOAuth2Account *anAccount = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject];
        
        if(anAccount) {
            //NSLog(@"Using Account: %@", anAccount);
            
            [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                                     secret:@"testsecret"
                                           authorizationURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                                   tokenURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                                redirectURL:[NSURL URLWithString:@"http://51seven.de:8888/"]
                                             forAccountType:@"password"];
            
             NXOAuth2Request *theRequest = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:@"http://51seven.de:8888/api/list/3"]
                                                                              method:@"POST"
                                                                          parameters:nil];
            
            theRequest.account = anAccount;
            
            NSURLRequest *signedRequest = [theRequest signedURLRequest];
            NSData *returnData = [NSURLConnection sendSynchronousRequest: signedRequest returningResponse: nil error: nil];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            if(returnString != nil) {
                NSMenu *menu = [((AppDelegate *)[[NSApplication sharedApplication] delegate]) menuBarOutlet];
                
                NSLog(@"> Number of menuitems: %ld", (long)[menu numberOfItems]);
                
                id json_response = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
                
                if([json_response count]) {
                    int recentSnapsBeginIndex = (int)[menu indexOfItemWithTitle:@"seperatorRecentSnapsBegin"];
                    int recentSnapsEndIndex = (int)[menu indexOfItemWithTitle:@"seperatorRecentSnapsEnd"];

                    NSLog(@"Removing Items from %d to %d", recentSnapsBeginIndex+1, recentSnapsEndIndex+1);
                    
                    // Removing all recent Snaps
                    for (int i = recentSnapsBeginIndex+1; i < recentSnapsEndIndex; i++) {
                        [menu removeItemAtIndex:i];
                        NSLog(@"removed item at index %d", i);
                    }
                    
                    // Adding the new ones
                    //NSLog(@"Adding Items from %d to %d", recentSnapsBeginIndex+1, recentSnapsBeginIndex+ 1+(int)[json_response count]);
                    for (int i = 0; i < [json_response count]; i++) {
                        NSDictionary *dict = [json_response objectAtIndex: i];
                        //NSLog(@"Adding item (%d) at %d", i, recentSnapsBeginIndex+(i+1));
                        [menu insertItemWithTitle:[NSString stringWithFormat: @"%d - %@", i, [dict objectForKey: @"title"]] action:nil keyEquivalent:@"" atIndex:recentSnapsBeginIndex+(i+1)]; // @selector(openRecentSnap:)
                        
                        // Download the image thumbnail
                        // Not needed for debug
                        /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                       ^{
                                           NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@", [dict objectForKey: @"uri"]]];
                                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                                           
                                           //This is your completion handler
                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                               [[menu itemAtIndex:recentSnapsBeginIndex+(i+1)] setImage: [[NSImage alloc] initWithData:imageData]];
                                           });
                                       });*/
                    }
                }
                else {
                    NSLog(@"You dont have any snaps yet :(");
                }
            }
            else {
                NSLog(@"Request failed.");
            }
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
