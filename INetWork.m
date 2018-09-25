//
//  INetWork.m
//  MangoSDK
//
//  Created by 雷琦玮 on 2018/9/6.
//  Copyright © 2018年 雷琦玮. All rights reserved.
//

#import "INetWork.h"
#import "IDevice.h"
#import <Foundation/Foundation.h>
@interface INetWork ()
@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@end

@implementation INetWork
/**
 * GET网络请求
 */
- (NSNumber *)getDataWithUrl:(NSString *)url Params:(id )params CompletionHandler:(void(^)(BOOL isSuccess, id result,id header))completionHandler{
    NSNumber *requestId = [self generateRequestId];
    self.dispatchTable[requestId] = [self.afnManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (completionHandler) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            completionHandler(YES,responseObject,allHeaders);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completionHandler) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            completionHandler(NO,error,allHeaders);
        }
        
    }];
    return requestId;
}

/**
 * POST网络请求
 */
- (NSNumber *)postDataWithUrl:(NSString *)url Params:(id )params CompletionHandler:(void(^)(BOOL isSuccess, id result,id header))completionHandler{
    NSNumber *requestId = [self generateRequestId];
    self.dispatchTable[requestId] = [self.afnManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if (completionHandler) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            
            completionHandler(YES,responseObject,allHeaders);
         
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        if (completionHandler) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            completionHandler(NO,error,allHeaders);
        }
        
    }];
    return requestId;
}

/**
 * 上传网络请求
 */
- (NSNumber *)uploadDataWithUrl:(NSString *)url
                         Params:(NSDictionary *)params
                           Data:(NSData *)data
                       FileName:(NSString *)fileName
              CompletionHandler:(void(^)(BOOL isSuccess, id result, id header))completionHandler{

    NSNumber *requestId = [self generateRequestId];
    self.dispatchTable[requestId] = [self.afnManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:data name:fileName];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completionHandler) {
            
            completionHandler(YES,responseObject,task.response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completionHandler) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSDictionary *allHeaders = response.allHeaderFields;
            completionHandler(NO,error,allHeaders);
        }
    }];
    return requestId;
}

/**
  * 下载
 */
- (NSNumber *)downloadDataWithUrl:(NSString *)url Params:(NSDictionary *)params CompletionHandler:(void(^)(BOOL isSuccess, id result ,id header))completionHandler{
    //构建可变的urlRequest
    NSMutableURLRequest*urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    //添加请求体
    [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil]];
    //添加请求方式
    [urlRequest setHTTPMethod:@"POST"];
    //添加请求头
    for (NSString * subKey in self.afnManager.requestSerializer.HTTPRequestHeaders.allKeys) {
        [urlRequest setValue:self.afnManager.requestSerializer.HTTPRequestHeaders[subKey] forHTTPHeaderField:subKey];
    }
    //请求id
    NSNumber *requestId = [self generateRequestId];
//=================================================开始下载请求================================================================================
    NSURLSessionDownloadTask *downloadTask = [self.afnManager downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        NSLog(@"当前下载进度为:%lf", 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //返回下载存储地址
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:targetPath.lastPathComponent];
        //临时的存储目录
        NSLog(@"targetPath:%@",targetPath);
        //下载存储最终的目录
        NSLog(@"fullPath:%@",fullPath);
        return [NSURL fileURLWithPath:fullPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        // 下载完成
        if (!error) {
            if (completionHandler) {
                completionHandler(YES, filePath,response);
            }
        }else{
            if (completionHandler) {
                completionHandler(NO, filePath,response);
            }
        }
        
    }];
    [downloadTask resume];
//=================================================完成下载请求================================================================================
    self.dispatchTable[requestId] = downloadTask;
    return requestId;
}

/**
 * 取消网络请求
 */
- (BOOL)cancelWithRequestTag:(NSInteger)requestTag{
    NSURLSessionTask *task = [self.dispatchTable objectForKey:@(requestTag)];
    if (task) {
        [task cancel];
        [self.dispatchTable removeObjectForKey:@(requestTag)];
        return YES;
    }
    return NO;
   
}


/**
 * 向网络请求添加多个通用的header
 */
- (NSDictionary *)addHeaderWithHeaders:(NSDictionary<NSString *, NSString *> *)headers{
    [self.afnManager.requestSerializer setValue:[[IDevice sharedInstance] udid]   forHTTPHeaderField:@"mobileid"];
    [self.afnManager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.afnManager.requestSerializer setValue:[self generateUUID]               forHTTPHeaderField:@"requestNo"];
    [self.afnManager.requestSerializer setValue:@"keep-alive"                     forHTTPHeaderField:@"Connection"];
    if (headers) {
        for (NSString *subKey in headers.allKeys) {
             [self.afnManager.requestSerializer setValue:headers[subKey] forHTTPHeaderField:subKey];
        }
    }
    return self.afnManager.requestSerializer.HTTPRequestHeaders;
}

#pragma mark - recycle methods
+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static INetWork *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[INetWork alloc] init];
    });
    return sharedInstance;
}
//请求ID自增
- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}
//收纳各种请求的字典
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}
//请求的单例对象 AFURLSessionManager的子类
-(AFHTTPSessionManager *)afnManager{
    if (_afnManager == nil) {
        _afnManager = [AFHTTPSessionManager manager];
        _afnManager.requestSerializer  = [AFJSONRequestSerializer serializer]; //请求体json序列号
        //添加请求头
        [self addHeaderWithHeaders:nil];
    }
    return _afnManager;
}

- (NSString *)generateUUID{
    NSString *result = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid){
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    return result;
}
@end
