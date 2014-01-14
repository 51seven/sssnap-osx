//
//  checkSignedIn.m
//  sssnap
//
//  Created by Christian Poplawski on 14.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "checkSignedIn.h"

@implementation checkSignedIn{
    BOOL isSignedIn;
}

-(BOOL)checkSignInStatus {
    
    if(isSignedIn){
        return true;
    }
    else{
        return false;
    }
}

-(void) SignedIn {
    isSignedIn = true;
}

-(void) notSignedIn {
    isSignedIn = false;
}

@end
