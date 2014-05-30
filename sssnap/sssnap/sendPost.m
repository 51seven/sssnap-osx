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

// Authenticates against username and password. Returns unique user token if success.

// Sends an HTTP POST-Request
// s. pastebin.com/R70NJMnQ
- (void)uploadImage:(NSImage *) image{

    NSLog(@"Event Caught - Initializing Upload");
    functions *function = [[functions alloc] init];

    //RP: Creando el request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    // RP: Empaquetando datos
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    //RP: Configurando la dirección
    NSString *serverUrl = @"http://localhost:3000";
        //    NSString *serverUrl = @"http://51seven.de:8888";
    
    NXOAuth2Account *anAccount = [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject];
    NSLog(@"Account for request: %@", anAccount.accessToken);
    
    NSString *uri = [NSString stringWithFormat:@"%@/api/upload?access_token=%@", serverUrl, [anAccount.accessToken accessToken]];
    NSURL *requestURL = [[NSURL alloc] initWithString:uri];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // -----------------------------------------
    // add image data
    // -----------------------------------------
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData: imageData];
    imageData = [imageRep representationUsingType:NSPNGFileType properties: nil];
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setURL:requestURL];
    
    // Check if token is expired
    if([function dateIsExpired: anAccount.accessToken.expiresAt]) {
        NSLog(@"token expired");
        
        //[[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"refresh_token"];
    
       NSDictionary *parameters = @{
                                    @"grant_type": @"refresh_token",
                                    @"client_id": @"testid",
                                    @"client_secret": @"testsecret",
                                    @"refresh_token": anAccount.accessToken.refreshToken
       };
        
//        [[NXOAuth2AccountStore sharedStore] refreshAccessToken];
        
        /*[[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                                 secret:@"testsecret"
                                       authorizationURL:[NSURL URLWithString:@"http://localhost:3000/api/oauth/token"]
                                               tokenURL:[NSURL URLWithString:@"http://localhost:3000/api/oauth/token"]
                                            redirectURL:[NSURL URLWithString:@"http://localhost:3000/"]
                                         forAccountType:@"password"];
        
        [NXOAuth2Request performMethod:@"POST"
                            onResource:[NSURL URLWithString: @"http://localhost:3000/api/test"]
                       usingParameters:parameters
                           withAccount:anAccount
                   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                       
                   }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                       NSLog(responseData);
                   }];
        */
    }
    
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *response_str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    NSData *response_data = [response_str dataUsingEncoding:NSUTF8StringEncoding];
    id json_response = [NSJSONSerialization JSONObjectWithData:response_data options:0 error:nil];
    
    // handle reponse
    /*if([json_response objectForKey:@"code"]) {
     if([[json_response objectForKey:@"code"] isEqualToNumber: [NSNumber numberWithInt:401]]) {
     NSLog(@"An Error occured: %@", [json_response objectForKey:@"error_description"]);
     }
     }
     else {
     [function sendGrowl: response_str];
     [function copyToClipboard: response_str];
     }*/
    
    // Send Notification and copy link to clipboard
    [function sendGrowl: response_str];
    [function copyToClipboard: response_str];
}


@end
