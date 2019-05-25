//
//  TCReachabilityManager.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/26/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface TCReachabilityManager : NSObject

@property (strong, nonatomic) Reachability *reachability;

+ (TCReachabilityManager *)sharedManager;

- (BOOL)isReachable;
- (BOOL)isUnreachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

@end
