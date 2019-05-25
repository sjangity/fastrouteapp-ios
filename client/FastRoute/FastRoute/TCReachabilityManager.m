//
//  TCReachabilityManager.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/26/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import "TCReachabilityManager.h"

#import "Reachability.h"

@implementation TCReachabilityManager

+ (TCReachabilityManager *)sharedManager
{
    static TCReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
        
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc
{
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

- (BOOL)isReachable {
    return ([[[TCReachabilityManager sharedManager] reachability] currentReachabilityStatus] != NotReachable);
}
 
- (BOOL)isUnreachable {
    return ![self isReachable];
}
 
- (BOOL)isReachableViaWWAN {
    return ([[[TCReachabilityManager sharedManager] reachability] currentReachabilityStatus] == ReachableViaWWAN);
}
 
- (BOOL)isReachableViaWiFi {
    return ([[[TCReachabilityManager sharedManager] reachability] currentReachabilityStatus] == ReachableViaWiFi);
}

@end
