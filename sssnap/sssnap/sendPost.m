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
        
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary]; // Environment Variables
        
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData: imageData];
        imageData = [imageRep representationUsingType:NSPNGFileType properties: nil];
        
        NSDictionary *parameters = @{
                                     @"file": imageData,
                                     };
        
        NXOAuth2Account *anAccount = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject];
        if(anAccount) {
            //NSLog(@"Using Account: %@", anAccount);
        
            [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                                     secret:@"testsecret"
                                           authorizationURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@/api/oauth/token", infoDict[@"serverurl"]]]
                                                   tokenURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@/api/oauth/token", infoDict[@"serverurl"]]]
                                                redirectURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@", infoDict[@"serverurl"]]]
                                             forAccountType:@"password"];
            
            [[NXOAuth2AccountStore sharedStore] setTrustModeHandlerForAccountType:@"password" block:^NXOAuth2TrustMode(NXOAuth2Connection *connection, NSString *hostname) {
                return NXOAuth2TrustModeAnyCertificate;
            }];
        
            [NXOAuth2Request performMethod:@"POST"
                                onResource:[NSURL URLWithString: [NSString stringWithFormat: @"%@/api/snap/", infoDict[@"serverurl"]]]
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
                           // Just debugging
                           //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                           //NSLog(@"ResponseData: %@", responseString);
                           
                           id json_response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                           
                           if([[json_response objectForKey:@"status"] isLike: @"ok"]) {
                               NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
                               
                               if([userPreferences boolForKey: @"showDesktopNotifications"]) {
                                   [functions sendGrowl: [[json_response objectForKey:@"payload"] objectForKey: @"url"]];
                               }
                               if([userPreferences boolForKey: @"copyLinkToClipboard"]) {
                                   [functions copyToClipboard: [[json_response objectForKey:@"payload"] objectForKey: @"url"]];
                               }
                           }
                           else {
                               NSLog(@"An error occured: %@", error);
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
// One does not simply use a caching method here.
- (void)getRecentSnaps {
    
    NSMenu *menu = [((AppDelegate *)[[NSApplication sharedApplication] delegate]) menuBarOutlet];
    
    int recentSnapsBeginIndex = (int)[menu indexOfItemWithTitle:@"seperatorRecentSnapsBegin"];
    int recentSnapsEndIndex = (int)[menu indexOfItemWithTitle:@"seperatorRecentSnapsEnd"];
    
    // Removing all recent Snaps
    // Actually we are removing the number of items between the first seperator and the second one.
    // Care: after deliting an item, the others fill the missing index.
    /*for (int i = 0; i < recentSnapsEndIndex-recentSnapsBeginIndex-1; i++) {
        [menu removeItemAtIndex:i];
        NSLog(@"removed item with title: %@", [[menu itemAtIndex:i] title]);
    }*/
    for (int i = recentSnapsEndIndex-1; i > recentSnapsBeginIndex; i--) {
        [menu removeItemAtIndex:i];
    }
    
    // Check if we're connected to the internet
    if([[Reachability reachabilityForInternetConnection] isReachable]) {
        
        NXOAuth2Account *anAccount = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary]; // Environment Variables
        
        if(anAccount) {
            [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                                     secret:@"testsecret"
                                           authorizationURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@/api/oauth/token", infoDict[@"serverurl"]]]
                                                   tokenURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@/api/oauth/token", infoDict[@"serverurl"]]]
                                                redirectURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@", infoDict[@"serverurl"]]]
                                             forAccountType:@"password"];
            
            [[NXOAuth2AccountStore sharedStore] setTrustModeHandlerForAccountType:@"password" block:^NXOAuth2TrustMode(NXOAuth2Connection *connection, NSString *hostname) {
                return NXOAuth2TrustModeAnyCertificate;
            }];
            
            NXOAuth2Request *theRequest = [[NXOAuth2Request alloc] initWithResource:[NSURL URLWithString:[NSString stringWithFormat: @"%@/api/snap/list/5", infoDict[@"serverurl"]]]
                                                                              method:@"POST"
                                                                          parameters:nil];
            
            theRequest.account = anAccount;
            
            NSURLRequest *signedRequest = [theRequest signedURLRequest];
            NSData *returnData = [NSURLConnection sendSynchronousRequest: signedRequest returningResponse: nil error: nil]; // Change to Asynchronus Request
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            
            if(returnString != nil) {
                id json_response = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
                
                if([[json_response objectForKey:@"status"] isLike: @"ok"]) {
                    // Adding the new ones
                    for (int i = 0; i < [[json_response objectForKey: @"payload"] count]; i++) {
                        
                        NSString *snaptitle = [NSString stringWithFormat: @"%@", [[[json_response objectForKey: @"payload"] objectAtIndex:i] objectForKey:@"title"]];
                        NSString *snapcount = [NSString stringWithFormat: @"%@", [[[json_response objectForKey: @"payload"] objectAtIndex:i] objectForKey:@"hits"]];
                        NSString *itemtitle = [NSString stringWithFormat: @"%@ (%@)", snaptitle, snapcount];
                        
                        NSMenuItem *currentitem = [[NSMenuItem alloc] initWithTitle:itemtitle action:@selector(someUrlAction:) keyEquivalent:@""];
                        [currentitem setTarget:self];
                        [currentitem setAction:@selector(someUrlAction:)];
                        [menu insertItem:currentitem atIndex:recentSnapsBeginIndex+(i+1)];
                        
                        // Download the image thumbnail
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                       ^{
                                           NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@", [[[json_response objectForKey: @"payload"] objectAtIndex:i] objectForKey:@"thumb"]]];
                                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                                           NSImage *image = [[NSImage alloc] initWithData:imageData];
                                           
                                           // Downscaling not needed ATM. But i'll just uncomment it. We'll never know
                                           /*NSInteger height = 34;
                                           NSInteger width = 60;
                                           
                                           NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                                                                    initWithBitmapDataPlanes:NULL
                                                                    pixelsWide:width
                                                                    pixelsHigh:height
                                                                    bitsPerSample:8
                                                                    samplesPerPixel:4
                                                                    hasAlpha:YES
                                                                    isPlanar:NO
                                                                    colorSpaceName:NSCalibratedRGBColorSpace
                                                                    bytesPerRow:0
                                                                    bitsPerPixel:0];
                                           [rep setSize:NSMakeSize(width, height)];
                                           
                                           [NSGraphicsContext saveGraphicsState];
                                           [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];

                                           [image drawInRect:NSMakeRect(0, 0, width, height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
                                           [NSGraphicsContext restoreGraphicsState];
                                           
                                           NSData *newImageData = [rep representationUsingType:NSPNGFileType properties:nil];
                                           NSImage *scaledImage = [[NSImage alloc] initWithData:image];
                                            */
                                           
                                           //This is your completion handler
                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                               [currentitem setImage: image];
                                           });
                                       });
                    }
                }
                else {
                    NSMenuItem *menuitem = [menu insertItemWithTitle:@"You dont have any snaps yet :(" action:nil keyEquivalent:@"" atIndex:recentSnapsBeginIndex+1];
                    [menuitem setEnabled:NO];
                }
            }
            else {
                NSLog(@"Request for recent snaps failed: Result is empty.");
            }
        }
        else {
            NSLog(@"Request for recent snaps failed: User is not logged-in.");
        }
    }
    else {
        NSLog(@"Request for recent snaps failed: No internet connection.");
    }
}

-(void)someUrlAction:(id) sender {
    NSLog(@"Opening URL...");
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://51seven.de"]];
}
-(void)someUrlAction {
    NSLog(@"Opening URL...");
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://51seven.de"]];
}

@end



// Fixes HTTPS Issues.
// Found on stackoverflow: stackoverflow.com/questions/21025622/http-load-failed-kcfstreamerrordomainssl-9813-in-cordova-app
@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end
