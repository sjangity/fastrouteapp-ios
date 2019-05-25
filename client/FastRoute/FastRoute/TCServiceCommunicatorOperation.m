//
//  TCServiceCommunicatorOperation.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import "FastRoute-Swift.h"
#import "TCServiceCommunicatorOperation.h"

/*!

 @typedef NS_ENUM (NSUInteger, OperationState)

 @abstract
 Tracks Asynchrnous Network operation status.

 @discussion

 */
typedef NS_ENUM(short, OperationState) {
    /*! Paused State */
    OperationPausedState      = -1,
    
    /*! Ready State */
    OperationReadyState       = 1,
    
    /*! Executing State */
    OperationExecutingState   = 2,
    
    /*! Finished State */
    OperationFinishedState    = 3,
};

static inline NSString * KeyPathFromOperationState(OperationState state) {
    switch (state) {
        case OperationReadyState:
            return @"isReady";
        case OperationExecutingState:
            return @"isExecuting";
        case OperationFinishedState:
            return @"isFinished";
        case OperationPausedState:
            return @"isPaused";
        default:
            return @"state";
    }
}

static inline BOOL StateTransitionIsValid(OperationState fromState, OperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case OperationReadyState:
            switch (toState) {
                case OperationPausedState:
                case OperationExecutingState:
                    return YES;
                case OperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case OperationExecutingState:
            switch (toState) {
                case OperationPausedState:
                case OperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case OperationFinishedState:
            return NO;
        case OperationPausedState:
            return toState == OperationReadyState;
        default:
            return YES;
    }
}

@interface TCServiceCommunicatorOperation() <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (readwrite, nonatomic, retain) NSRecursiveLock *lock;
@property (readwrite, nonatomic, assign) OperationState state;
@property (readwrite, nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (readwrite, nonatomic, retain) NSURLConnection *connection;
@property (readwrite, nonatomic, retain) NSError *error;
@property (readwrite, nonatomic, retain) NSURLCredential *defaultCredential;
@end

@implementation TCServiceCommunicatorOperation

@synthesize request = _request;
@synthesize state = _state;
@synthesize cancelled = _cancelled;
@synthesize statusCode = _statusCode;
@synthesize responseData = _responseData;
@synthesize error = _error;
@synthesize connection = _connection;
@synthesize defaultCredential = _defaultCredential;
@synthesize lock = _lock;

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
    self = [super init];
    if (self)
    {
        self.request = urlRequest;
        
        self.state = OperationReadyState;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"com.peerflight.networking.operation.lock";
    }
    return self;
}

- (void)dealloc
{
//    [_connection release];
    DLog(@"Dealloc called");
    _lock = nil;
    _request = nil;
    _connection = nil;
    _responseData = nil;
    _error = nil;
}

- (void)setState:(OperationState)state {
//    [self.lock lock];
    if (StateTransitionIsValid(self.state, state, [self isCancelled])) {
    
        NSString *oldStateKey = KeyPathFromOperationState(self.state);
        NSString *newStateKey = KeyPathFromOperationState(state);
        
        [self willChangeValueForKey:newStateKey];
        [self willChangeValueForKey:oldStateKey];
        _state = state;
        [self didChangeValueForKey:oldStateKey];
        [self didChangeValueForKey:newStateKey];
    }
    
//        [self willChangeValueForKey:KeyPathFromOperationState(state)];
//        _state = state;
//        [self didChangeValueForKey:KeyPathFromOperationState(state)];
//
//        DLog(@"Current State = %@", KeyPathFromOperationState(state));


//        [self.lock unlock];
}

- (void)setCustomCompletionBlock:(void (^)(TCServiceCommunicatorOperation *operation, id responseObject))success failure:(void (^)(TCServiceCommunicatorOperation *operation, NSError *error))failure
{
    DLog(@"OPERATION: setCustomCompletionBlock");
    __block TCServiceCommunicatorOperation *weakOperation = self;
    self.completionBlock = ^{
        TCServiceCommunicatorOperation *strongOperation = weakOperation;
        if (strongOperation.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(),^{
                    failure(strongOperation,strongOperation.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(strongOperation, strongOperation.responseData);
                });
            }
        }
    };
}

- (void)setDefaultCredentials:(NSURLCredential *)credential
{
    self.defaultCredential = credential;
}

#pragma mark NSOperation

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady {
    return self.state == OperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == OperationExecutingState;
}

- (BOOL)isFinished {
    return self.state == OperationFinishedState;
}

- (void)start
{
    DLog(@"OPERATION: start");
    [self.lock lock];
    if([self isReady])
    {
        self.state = OperationExecutingState;
// https://github.com/samvermette/svhttprequest/issues/16
// https://github.com/samvermette/SVHTTPRequest/commit/276ae99f4235b9761a3bccf3eee9b2bc2602dfdf
//        if(![NSThread isMainThread]) { // NSOperationQueue calls start from a bg thread (through GCD), but NSURLConnection already does that by itself
//            [self performSelectorOnMainThread:@selector(operationStart) withObject:nil waitUntilDone:NO];
//            return;
//        }
//        [self performSelector:@selector(operationDidStart)
//            onThread:[[self class] networkRequestThread]
//            withObject:nil
//            waitUntilDone:NO
//            modes:[NSArray arrayWithObject:@"NSDefaultRunLoopMode"]];

//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self operationStart];
//            });

        [self performSelector:@selector(operationStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[[NSSet setWithObject:NSRunLoopCommonModes] allObjects]];

    }
    [self.lock unlock];
}

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (void)operationStart
{
    DLog(@"OPERATION: operationStart");
    [self.lock lock];
    if ([self isCancelled]) {
        [self finish];
    } else {
//        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.connection cancel];
        
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        for (NSString *runLoopMode in [NSSet setWithObject:NSRunLoopCommonModes]) {
            [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
        }
        
        [self.connection start];

    }
    [self.lock unlock];
}

- (void)finish
{
    DLog(@"OPERATION: finish");

    self.state = OperationFinishedState;
    
    self.connection = nil;
    
//    [_lock unlock];
}

//- (void)cancel {
//    [self.lock lock];
//    if (![self isFinished] && ![self isCancelled]) {
//        [self willChangeValueForKey:@"isCancelled"];
//        _cancelled = YES;
//        [super cancel];
//        [self didChangeValueForKey:@"isCancelled"];
//
//        // Cancel the connection on the thread it runs on to prevent race conditions 
//        [self performSelector:@selector(cancelConnection) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[[NSSet setWithObject:NSRunLoopCommonModes] allObjects]];
//    }
//    [self.lock unlock];
//}
//
//- (void)cancelConnection {
//    if (self.connection) {
//        [self.connection cancel];
//        
//        // Manually send this delegate message since `[self.connection cancel]` causes the connection to never send another message to its delegate
//        NSDictionary *userInfo = nil;
//        if ([self.request URL]) {
//            userInfo = [NSDictionary dictionaryWithObject:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
//        }
//        [self performSelector:@selector(connection:didFailWithError:) withObject:self.connection withObject:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo]];
//    }
//}

#pragma mark NSURLConnectionDataDelegate messages

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    DLog(@"Connection: did receive response. Here are the details.");

    self.responseData = [[NSMutableData alloc] init];
    DLog(@"Response = %@", response);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.statusCode = httpResponse.statusCode;
    DLog(@"NEW STATUS CODE = %li", (long)self.statusCode);
    DLog(@"%@",httpResponse);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    DLog(@"Connection: did receive data.");
    
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"Connection: did finish loading.");
    
    if (self.statusCode != 200)
    {
        DLog(@"Response = %@", self.responseData);
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful due to an internal error. Please contact support.", nil)
        };
        NSError *error = [NSError errorWithDomain:@"mobile.peerflight.com"
                                         code:self.statusCode
                                     userInfo:userInfo];
        self.error = error;
    }

    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DLog(@"ERROR: operation failed.");
    
    self.error = error;
    
    [self finish];
}

#pragma mark NSURLConnectionDelegate messages

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    DLog(@"AUTH CHALLENGE RECEIVED");
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // Constant declared in AppUtil.swift
        if ([challenge.protectionSpace.host isEqualToString:[GlobalConstant kHostPartialString]])
        {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }

        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
        if ([challenge previousFailureCount] == 0)
        {
            NSURLCredential *newCredential;
            
            if (self.defaultCredential)
            {
                newCredential = self.defaultCredential;
            } else {
                NSURLCredential *newCredential;
                newCredential = [NSURLCredential credentialWithUser:@"baduser"
                            password:@"badpass"
                            persistence:NSURLCredentialPersistenceForSession];
                [[challenge sender] cancelAuthenticationChallenge:challenge];
            }
            
            [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        }
        else
        {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            
            // inform user that auth failed: didFailedWithError delegate message is sent automatically
        }
    } else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

#pragma mark - Copying
- (id)copyWithZone:(NSZone*)zone {
    TCServiceCommunicatorOperation *copy = [[[self class] allocWithZone:zone] init];
    return copy;
}

@end
