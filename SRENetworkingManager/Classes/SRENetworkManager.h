//
//  SRENetworkManager.h
//  Soirée
//
//  Created by Shady Gabal on 12/27/15.
//  Copyright © 2015 Shady Gabal. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "IDVerificationPageViewController.h"
#import "AFNetworking.h"

/**
 *  Singleton that handles all network requests within app. Has option of taking in outside network manager or using its own. Provides simple success and error callback based approach to making network requests
 */

@interface SRENetworkManager : NSObject

/** @name Header Properties */

@property (nonatomic, strong) AFURLSessionManager * manager;

/** @name Header Methods */

/**
 *  Shared instance of network manager to ensure only one instance is generated.
 *
 *  @return network manager instance
 */
+(instancetype) sharedInstance;

/**
 *  Perform network request with custom AFURLSessionManager
 *
 *  @param manager         AFURLSessionManager
 *  @param url             URL to make request to
 *  @param method          mainly POST or GET, among others
 *  @param pars            parameters to pass in network request
 *  @param successCallback callback to be executed with id responseObject if request succeeds
 *  @param errorCallback   errorCallback to be executed with NSInteger statusCode, NSError error, and id responseObject
 */
//-(void) networkRequestWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback errorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject)) errorCallback;
/**
 *  Perform network request using SRENetworkManager's AFURLSessionManager
 *
 *  @param url             URL to make request to
 *  @param method          mainly POST or GET, among others
 *  @param pars            parameters to pass in network request
 *  @param successCallback callback to be executed with id responseObject if request succeeds
 *  @param errorCallback   errorCallback to be executed with NSInteger statusCode, NSError error, and id responseObject
 */
//-(void) networkRequestWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback errorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject)) errorCallback;

/**
 *  Perform network request with custom AFURLSessionManager and extended error callback
 *
 *  @param manager         AFURLSessionManager
 *  @param url             URL to make request to
 *  @param method          mainly POST or GET, among others
 *  @param pars            parameters to pass in network request
 *  @param successCallback callback to be executed with id responseObject if request succeeds
 *  @param extendedErrorCallback   errorCallback to be executed with NSInteger statusCode, NSError error, id responseObject, and NSString errorCode
 */
-(void) networkRequestWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback extendedErrorCallback:(void(^)(NSInteger statusCode, NSError *error, id responseObject, NSString * errorString)) errorCallback;

/**
 *  Perform network request with SRENetworkManager's AFURLSessionmanager and a simplified error callback
 *
 *  @param manager         AFURLSessionManager
 *  @param url             URL to make request to
 *  @param method          mainly POST or GET, among others
 *  @param pars            parameters to pass in network request
 *  @param successCallback callback to be executed with id responseObject if request succeeds
 *  @param simpleErrorCallback   errorCallback to be executed with NSInteger statusCode, NSError error, id responseObject, and NSString errorCode
 */

//-(void) networkRequestWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback;

/**
 *  Perform network request with custom AFURLSessionmanager and a simplified error callback
 *
 *  @param manager         AFURLSessionManager
 *  @param url             URL to make request to
 *  @param method          mainly POST or GET, among others
 *  @param pars            parameters to pass in network request
 *  @param successCallback callback to be executed with id responseObject if request succeeds
 *  @param simpleErrorCallback   errorCallback to be executed with NSInteger statusCode, NSError error, id responseObject, and NSString errorCode
 */
-(void) networkRequestSimpleWithManager:(AFURLSessionManager *) manager url:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback;

/**
 *  Perform network request with SRENetworkManager's AFURLSessionmanager and a simplified error callback
 *
 *  @param url             URL to make request to
 *  @param method          mainly POST or GET, among others
 *  @param pars            parameters to pass in network request
 *  @param successCallback callback to be executed with id responseObject if request succeeds
 *  @param simpleErrorCallback   errorCallback to be executed with NSInteger statusCode, NSError error, id responseObject, and NSString errorCode
 */

-(void) networkRequestSimpleWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback;

-(void) networkRequestSimpleWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback responseObjectErrorCallback:(void(^)(NSString * errorString, id responseObject)) errorCallback;

-(void) networkRequestWithoutUserDataWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback simpleErrorCallback:(void(^)(NSString * errorString)) errorCallback;

-(void) networkRequestWithoutUserDataWithUrl:(NSString *) url method:(NSString *) method parameters:(NSDictionary *) pars successCallback:(void(^)(id responseObject))successCallback responseObjectErrorCallback:(void(^)(NSString * errorString, id responseObject)) errorCallback;
/**
 *  Uploads Images To The Server
 *
 *  @param data            Array Of Dicts Representing Images
 *  @param url             url to send request to
 *  @param pars            custom parameters
 *  @param uploadProgressBlock  block to execute during upload
 *  @param retries         number of times to retry attempt
 *  @param successCallback callback on success
 *  @param errorCallback   callback on error
 */

-(void)uploadImagesWithData:(NSArray<NSDictionary *> *)data Url:(NSString *)url parameters:(NSDictionary *)pars progress:(nullable void (^)(NSProgress *_Nonnull __strong)) uploadProgressBlock retries:(int)retries successCallback:(void (^)(id))successCallback errorCallback:(void (^)(NSString *))errorCallback;

/**
 *  Retrieves errorCode from responseObject of a failed network request
 *
 *  @param responseObject responseObject of failed network request
 *
 *  @return error code
 */
+(NSString *) errorFromResponseObject:(id) responseObject;

@end
