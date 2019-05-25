//
//  TCServiceCommunicator.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014 Sandeep Jangity. All rights reserved.
//

#import "FastRoute-Swift.h"
#import "TCServiceCommunicator.h"
#import "TCServiceCommunicatorOperation.h"


@interface TCServiceCommunicator()
{
@private
    NSURLCredential *defaultCredential;
}

@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueuePush;
@property (readwrite, nonatomic, retain) NSMutableDictionary *defaultHeaders;
@end

@implementation TCServiceCommunicator

@synthesize operationQueue = _operationQueue;
@synthesize operationQueuePush = _operationQueuePush;
@synthesize defaultHeaders = _defaultHeaders;

+ (TCServiceCommunicator *)sharedCommunicator
{
    static TCServiceCommunicator *sharedCommunicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCommunicator = [[TCServiceCommunicator alloc] init];

        sharedCommunicator.operationQueue = [[NSOperationQueue alloc] init];
        [sharedCommunicator.operationQueue setMaxConcurrentOperationCount:3];

        sharedCommunicator.operationQueuePush = [[NSOperationQueue alloc] init];
        [sharedCommunicator.operationQueuePush setMaxConcurrentOperationCount:1];

        sharedCommunicator.defaultHeaders = [NSMutableDictionary dictionary];
        [sharedCommunicator setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
        [sharedCommunicator setDefaultHeader:@"Accept" value:@"application/json"];
        [sharedCommunicator setDefaultHeader:@"X-API-VERSION" value:[GlobalConstant kAPIVersionString]];
        NSData *nsdata = [[GlobalConstant kAPISecretString] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
        [sharedCommunicator setDefaultHeader:@"X-API-SIG" value:[NSString stringWithFormat:@"%@", encodedString]];
    });
    return sharedCommunicator;
}

#pragma mark Header manipulation

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
	[self.defaultHeaders setValue:value forKey:header];
}

- (NSString *)getHeaderValue:(NSString *)header
{
    return [self.defaultHeaders objectForKey:header];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)userName password:(NSString *)userPassword {
	NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", userName, userPassword];
    NSData *nsdata = [basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", encodedString]];

    defaultCredential = [NSURLCredential credentialWithUser:userName password:userPassword persistence:NSURLCredentialPersistenceNone];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)userName
{
    [self setDefaultHeader:@"X-Username" value:userName];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)userToken {
//    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", [userToken valueForKey:@"token"]]];
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[userToken valueForKey:@"token"], @"token", nil];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", [userToken valueForKey:@"token"]]];
}

- (void)clearAuthorizationHeader {
	[self.defaultHeaders removeObjectForKey:@"Authorization"];
}

- (void)clearAllHeaders {
    [self.defaultHeaders removeAllObjects];
}

#pragma mark Operation Management

- (TCServiceCommunicatorOperation *)Operation:(NSMutableURLRequest *)request success:(successBlock)success failure:(errorBlock)failure
{
    DLog(@"Processing Operation by NSOperation");
    [request setAllHTTPHeaderFields:self.defaultHeaders];

    // create & configure operation object
    TCServiceCommunicatorOperation *operation = [[TCServiceCommunicatorOperation alloc] initWithRequest:request];
    [operation setCustomCompletionBlock:(successBlock)success failure:(errorBlock)failure];
    
    if (defaultCredential) {
        [operation setDefaultCredentials:defaultCredential];
    }

    return operation;
}

- (TCServiceCommunicatorOperation *)POST:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(errorBlock)failure
{
    DLog(@"POST POST POST");
    
    NSString *requestURL = [[GlobalConstant kHostString] stringByAppendingString: url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [request setHTTPMethod:@"POST"]; // 1
    
    if ([parameters count])
    {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        DLog(@"DATA Error = %@", error);

        // generate request body (JSON)
        NSError *jsonSerializationError = nil;
        NSString *jsonString = nil;
        if(!jsonSerializationError) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"Serialized JSON: %@", jsonString);
        } else {
            DLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
        }
        NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

        [self setDefaultHeader:@"Content-Type" value:@"application/json"];
        [self setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] ];
        
        [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"X-API-VERSION" value:[GlobalConstant kAPIVersionString]];
        NSData *nsdata = [[GlobalConstant kAPISecretString] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
        [self setDefaultHeader:@"X-API-SIG" value:[NSString stringWithFormat:@"%@", encodedString]];
        [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];        
        
        
        [request setHTTPBody: requestData]; // 4
    }
    
    return [self Operation:request success:success failure:failure];
}

- (TCServiceCommunicatorOperation *)GET:(NSString *)url success:(successBlock)success failure:(errorBlock)failure
{
    DLog(@"Processing GET URL Request");
    // create request object
    NSString *requestURL = [[GlobalConstant kHostString] stringByAppendingString: url];
    DLog(@"Request URL: %", requestURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [request setHTTPMethod:@"GET"];
    
    [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-API-VERSION" value:[GlobalConstant kAPIVersionString]];
    NSData *nsdata = [[GlobalConstant kAPISecretString] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
    [self setDefaultHeader:@"X-API-SIG" value:[NSString stringWithFormat:@"%@", encodedString]];
    [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
    
    return [self Operation:request success:success failure:failure];
}

- (void)cancelAllHTTPOperations
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[TCServiceCommunicatorOperation class]]) {
            continue;
        }
        
        [operation cancel];
    }
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path {
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[TCServiceCommunicatorOperation class]]) {
            continue;
        }
        
        if ((!method || [method isEqualToString:[[(TCServiceCommunicatorOperation *)operation request] HTTPMethod]]) && [path isEqualToString:[[[(TCServiceCommunicatorOperation *)operation request] URL] path]]) {
            [operation cancel];
        }
    }
}

- (void)enqueueServiceOperations: (NSArray *)operations completionBlock:(void (^)(NSArray *operations))completionBlock
{
    DLog(@"OPERAITON: enqueueServiceOperations");

    // initialize dispatch group
    __block dispatch_group_t dispatchGroup = dispatch_group_create();
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(operations);
            }
        });
    }];

    for (TCServiceCommunicatorOperation *operation in operations)
    {    
        // configure operations completion block
        ServiceCompletionBlock originalCompletionBlock = [operation.completionBlock copy];
        operation.completionBlock = ^{
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_group_async(dispatchGroup, queue, ^{
                if (originalCompletionBlock) {
                    originalCompletionBlock();
                }
                dispatch_group_leave(dispatchGroup);
            });
        };
        
        dispatch_group_enter(dispatchGroup);
        // the batchedOperation should wait until the individual operations are compelete
        [batchedOperation addDependency:operation];
        
        [self.operationQueue addOperation: operation];
    }
    
    // add the batch operation to queue
    [self.operationQueue addOperation: batchedOperation];
}

#pragma mark File Management

- (void)checkIfJSONIsArrayOrDictionary:(id)response
{
    DLog(@"Checking if JSON returned from server is ARRAY/DICT");
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&jsonError];

    if ([jsonObject isKindOfClass:[NSArray class]]) {
        DLog(@"its an array!");
        NSArray *jsonArray = (NSArray *)jsonObject;
        DLog(@"jsonArray - %@",jsonArray);
    }
    else {
        DLog(@"its probably a dictionary");
        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
        DLog(@"jsonDictionary - %@",jsonDictionary);
    }
}

- (NSDictionary *)getJSONFromResponse:(id)response
{
    NSError *dictError = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: response options:0 error:&dictError];
    DLog(@"Response: %@", response);
    return dict;
}

- (void)saveJSONResponseToDisk: (id)responseObject withEntityName: (NSString *)className
{
    DLog(@"Saving JSON to disk");
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)responseObject writeToFile:[fileURL path] atomically:YES]){
        DLog(@"Error saving JSON response to disk");
    }
}

- (void)saveAddressJSONResponseToDisk: (id)responseObject withEntityName: (NSString *)className options: (NSDataWritingOptions)mask {
    DLog(@"Saving Adress JSON to disk");
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    [(NSData *)responseObject writeToFile:[fileURL path] options:mask error:&error];
    
    if (error != nil ) {
        DLog(@"Error saving JSON response to disk");
    }
}

- (NSDictionary *)getJSONFromDiskWithClassName:(NSString *)className
{
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:[fileURL path]];
    NSString *json_string = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSData *unicodeNotation = [json_string dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
    return JSONDictionary;
}

- (void)deleteJSONDataRecordsWithClassName:(NSString *)className
{
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        DLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *cacheDir = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [NSURL URLWithString:@"JSONResponses/" relativeToURL:cacheDir];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}


@end
