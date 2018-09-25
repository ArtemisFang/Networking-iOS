//
//  INetWork.h
//  MangoSDK
//
//  Created by 方媛 on 2018/9/6.
//  Copyright © 2018年 方媛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"


@interface INetWork : NSObject

@property(nonatomic,strong)AFHTTPSessionManager *afnManager;

+(instancetype)sharedInstance;

/**
 * 调用GET网络请求
 * @param url 地址
 * @param params 参数
 * @param completionHandler 回调
 */
- (NSNumber *)getDataWithUrl:(NSString *)url
                      params:(id )params
           completionHandler:(void(^)(BOOL isSuccess, id result,id header))completionHandler;
/**
 * 调用POST网络请求
 * @param url 地址
 * @param params 参数
 * @param completionHandler 回调
 */
- (NSNumber *)postDataWithUrl:(NSString *)url
                       params:(id )params
            completionHandler:(void(^)(BOOL isSuccess, id result,id header))completionHandler;

/**
 * 调用上传网络请求
 * @param url 地址
 * @param params 参数
 * @param data 文件流
 * @param fileName 文件名
 * @param completionHandler 回调
 */
- (NSNumber *)uploadDataWithUrl:(NSString *)url
                         Params:(NSDictionary *)params
                           Data:(NSData *)data
                       FileName:(NSString *)fileName
              CompletionHandler:(void(^)(BOOL isSuccess, id result, id header))completionHandler;

/**
 * 调用下载网络请求
 * @param url 地址
 * @param params 参数
 * @param completionHandler 回调
 */
- (NSNumber *)downloadDataWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                completionHandler:(void(^)(BOOL isSuccess, id result, id header))completionHandler;

/**
 * 取消网络请求
 * @param requestTag 请求标识位
 * @return 成功返回YES，失败返回NO
 */
- (BOOL)cancelWithRequestTag:(NSInteger)requestTag;

/**
 * 向网络请求添加多个通用的header
 * @param headers 集合，添加多个header
 */
- (NSDictionary *)addHeaderWithHeaders:(NSDictionary<NSString *, NSString *> *)headers;

@end
