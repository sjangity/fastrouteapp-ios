//
//  TCServiceCommunicatorOperation.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "TCutil.h"

@interface TCServiceCommunicatorOperation : NSOperation <NSCopying>

@property (readonly, nonatomic, retain) NSError *error;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, strong) NSMutableData *responseData;

- (id)initWithRequest:(NSURLRequest *)urlRequest;
- (void)setCustomCompletionBlock:(void (^)(TCServiceCommunicatorOperation *operation, id responseObject))success failure:(void (^)(TCServiceCommunicatorOperation *operation, NSError *error))failure;

- (void)setDefaultCredentials:(NSURLCredential *)credential;

@end
