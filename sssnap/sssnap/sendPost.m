//
//  sendPost.m
//  sssnap
//
//  Created by Sven Schiffer on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "sendPost.h"
#import <AppKit/AppKit.h>

@implementation sendPost

// Sends an HTTP POST-Request
- (void)sendPost:(NSImage *) image {
    NSLog(@"Event Cought - Initializing Upload");
    
    NSString *username = @"admin";
    NSString *password = @"geheim";
    
    //RP: Creando el request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    // RP: Empaquetando datos
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[NSString stringWithFormat:@"%@", username] forKey:@"username"];
    [_params setObject:[NSString stringWithFormat:@"%@", password] forKey:@"password"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'
    NSString *FileParamConstant = @"image_field";
    
    //RP: Configurando la dirección
    NSURL *requestURL = [[NSURL alloc] initWithString:@"http://api.sven-schiffer.de/sssnap_test.php"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // -----------------------------------------
    // add image data
    // -----------------------------------------
    NSData *imageData = [image TIFFRepresentation]; // -> UIImageJPEGRepresentation(imageToPost, 1.0);;
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData: imageData];
    imageData = [imageRep representationUsingType:NSPNGFileType properties: nil];
    
    if (imageData) {
        printf("appending image data\n");
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\"image.jpg\"\r\n",
                           FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // -----------------------------------------
    // end image
    // -----------------------------------------
    
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // NSLog(@"%@", [body description]);
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:requestURL];
    
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSLog(@"Response : %@",str);
    
}


@end