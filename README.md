# Networking-iOS
基于AFNetworking的二次封装，建立http请求的单例对象，提供GET网络请求，POST网络请求，上传，下载，取消指定的网络请求，添加请求头等


使用方法：
直接将下载的文件加入代码中
1.调用GET请求
  [[INetWork sharedInstance] getDataWithUrl:url params:params completionHandler:^(BOOL isSuccess, id result, id header) {
        if (isSuccess) {

        }else{

        }    
    }];
2.调用POST请求
 [[INetWork sharedInstance] postDataWithUrl:url params:params completionHandler:^(BOOL isSuccess, id result, id header) {
      if (isSuccess) {

      }else{

      } 
  }];
3.调用下载请求
 [[INetWork sharedInstance] downloadDataWithUrl:url params:params completionHandler:^(BOOL isSuccess, id result,id header) {
      if(isSuccess){
      
      }else{
      
      }
 }];
