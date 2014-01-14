//
//  checkSignedIn.h
//  sssnap
//
//  Created by Christian Poplawski on 14.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface checkSignedIn : NSObject

-(BOOL)checkSignInStatus;
-(void) notSignedIn;
-(void) SignedIn;

@end
