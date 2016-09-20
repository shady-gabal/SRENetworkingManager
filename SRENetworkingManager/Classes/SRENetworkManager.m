//
//  SRENetworkManager.m
//  Soirée
//
//  Created by Shady Gabal on 12/27/15.
//  Copyright © 2015 Shady Gabal. All rights reserved.
//

#import "SRENetworkManager.h"
#import "SoireeAccessToken.h"

static SRENetworkManager * networkManager;

#define k_NUM_TIMES_RETRY 2

@implementation SRENetworkManager

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        networkManager = [[SRENetworkManager alloc]init];
    });
    return networkManager;
}

-(instancetype) init{
    self = [super init];
    if (self){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

-(void) networkRequestWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback errorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject)) errorCallback{
    
//    NSMutableDictionary * parsMut = [pars mutableCopy];
//    
//    if (!parsMut[@"user"])
//        parsMut[@"user"] = [User sharedInstance].userData;
//    
//    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:pars error:nil];
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error){
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        
//        NSInteger statusCode = httpResponse.statusCode;
//        if (error || !responseObject || statusCode >= 400){//error performing request
//            return errorCallback(statusCode, error, responseObject);
//        }
//        else{//success
//            successCallback(responseObject);
//        }
//    }];
//    [dataTask resume];
    
    [self networkRequestWithManager:manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:^(NSInteger statusCode, NSError * error, id responseObject, NSString * errorString){
        errorCallback(statusCode, error, responseObject);
    }];
}

//-(void) networkRequestWithManager:(AFURLSessionManager *) manager urlSuffix:(NSString *) urlSuffix method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback extendedErrorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString)) errorCallback{
//    
//    NSString * url = [SRESharedMethods urlStringWithSuffix:urlSuffix];
//    [self networkRequestWithManager:manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:errorCallback];
//}

-(void) networkRequestWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback extendedErrorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString)) errorCallback numberOfRetries:(int) numRetries options:(NSDictionary *) options{
    
    int __block numberOfRetries = numRetries;
    if (!pars)
        pars = @{};
    if (!options)
        options = @{};
    
    NSMutableDictionary * parsMut = [pars mutableCopy];
    
    if (!parsMut[@"user"] && !options[@"dontIncludeUserData"])
        parsMut[@"user"] = [User sharedInstance].userData;
    parsMut[@"os"] = @"ios";
    
    void(^callback)(NSURLResponse *, id, NSError * error) = ^(NSURLResponse *response, id responseObject, NSError *error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSString * errorString = [SRENetworkManager errorFromResponseObject:responseObject];
        if (errorString && ([errorString isEqualToString:@"InvalidSoireeAccessToken"] || [errorString isEqualToString:@"UserAuthenticationError"])){
            if ([SoireeAccessToken currentAccessToken])
                [SoireeAccessToken invalidateCurrentAccessToken];
            
            [[RootNavController sharedInstance] showSignup];
        }
        
        NSInteger statusCode = httpResponse.statusCode;
        
        if (!errorString && error){
            
//            NSLog(@"Error on client side: %@", error);
            
            //get error code
            NSInteger errorStatusCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
            //if should retry and failed because of internet
            if (errorStatusCode >= 500 || errorStatusCode == 404 || errorStatusCode == 418){
                //wont help retrying
                return errorCallback(statusCode, error, responseObject, @"ServerError");
            }
            else if (numberOfRetries < k_NUM_TIMES_RETRY) {
                numberOfRetries++;
                return [self networkRequestWithManager:manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:errorCallback numberOfRetries:numberOfRetries options:options];
                return;
            }
            
            else return errorCallback(statusCode, error, responseObject, k_Error_Internet_Connection_Error);
        }
        
        else if (errorString && statusCode >= 400){//error performing request, received error code in response object
            NSLog(@"Error Code: %d", statusCode);
            return errorCallback(statusCode, error, responseObject, errorString);
        }
        else{//success
            successCallback(responseObject);
        }
    };
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method URLString:url parameters:parsMut error:nil];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:callback];
    [dataTask resume];
}

-(void) networkRequestWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback extendedErrorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString)) errorCallback{
    
    [self networkRequestWithManager:manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:errorCallback numberOfRetries:0 options:nil];
}


-(void) networkRequestSimpleWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback{
    
    [self networkRequestWithManager:manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:^(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString){
        errorCallback(errorString);
    }];
}


-(void) networkRequestSimpleWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback responseObjectErrorCallback:(void(^)(NSString * errorString, id responseObject)) errorCallback{
    
    [self networkRequestWithManager:self.manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:^(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString){
        errorCallback(errorString, responseObject);
    }];
}

-(void) networkRequestWithoutUserDataWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback{
    [self networkRequestWithManager:self.manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:^(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString){
        errorCallback(errorString);
    }numberOfRetries:0 options:@{@"dontIncludeUserData" : @(1)}];
}

-(void) networkRequestWithoutUserDataWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback responseObjectErrorCallback:(void(^)(NSString * errorString, id responseObject)) errorCallback{
    [self networkRequestWithManager:self.manager url:url method:method parameters:pars successCallback:successCallback extendedErrorCallback:^(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString){
        errorCallback(errorString, responseObject);
    }numberOfRetries:0 options:@{@"dontIncludeUserData" : @(1)}];
}



-(void) networkRequestSimpleWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback{
    [self networkRequestSimpleWithManager:self.manager url:url method:method parameters:pars successCallback:successCallback simpleErrorCallback:errorCallback];
}

#pragma mark - Uploading Images

-(void)uploadImagesWithData:(NSArray<NSDictionary *> *)data Url:(NSString *)url parameters:(NSDictionary *)pars progress:(nullable void (^)(NSProgress *_Nonnull __strong))uploadProgressBlock retries:(int)retries successCallback:(void (^)(id))successCallback errorCallback:(void (^)(NSString *))errorCallback{
    AFHTTPSessionManager * manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:pars constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
        for(NSDictionary * dataDict in data){
            NSData * data = [dataDict objectForKey:@"data"];
            NSString * name = [dataDict objectForKey:@"name"];
            NSString * fileName = [dataDict objectForKey:@"fileName"];
            NSString * mimeType = [dataDict objectForKey:@"mimeType"];
            
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
        }
    } error:nil];
    
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:uploadProgressBlock completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        
        if (error) {
            NSLog(@"Error sending photo: %@", error);
            if (retries < k_NUM_TIMES_RETRY){
                return [self uploadImagesWithData:data Url:url parameters:pars progress:uploadProgressBlock retries:retries + 1 successCallback:successCallback errorCallback:errorCallback];
            }
            else{
                NSString * errorCode = [SRENetworkManager errorFromResponseObject:responseObject];
                errorCallback(errorCode);
            }
        }
        else{
            successCallback(responseObject);
        }
    }];
    
    [task resume];
    
    
}


+(NSString *) errorFromResponseObject:(id) responseObject{
    if (!responseObject) return nil;
    if (![responseObject isKindOfClass:[NSDictionary class]]) return nil;
    if (!responseObject[@"error"]) return nil;

    NSString * error = responseObject[@"error"];
    if ([error isKindOfClass:[NSNull class]]) return @"Error";
    return error;
}

@end
