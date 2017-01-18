//
//  ZJInterface.m
//  MushRoomLamp
//
//  Created by SongGang on 7/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"
#import <AFNetworking/AFNetworking.h>

//NSString *const URL = @"https://118.178.21.0";
//NSString *const URL = @"https://api.shijia-zhijia.com";

NSString *const URL = @"http://118.178.21.0:8880";
//NSString *const URL = @"http://192.168.1.132:8880";


@implementation ZJInterface
- (instancetype)initWithDelegate:(id<ZJInterfaceDelegate>)delegate {
    self = [self init];
    if (self) {
        
        self.delegate   = delegate;
    }
    return self;
}

/**
 *  网络请求
 */
- (void)interfaceWithType:(INTERFACE_TYPE)type param:(NSDictionary *)param {
    switch (type) {
            
        case INTERFACE_TYPE_MESSAGECODE:
            [self RequestWithParam:param withUrl:@"/sms/send"];
            break;
        case INTERFACE_TYPE_REGISTER:
            [self RequestWithParam:param withUrl:@"/user/register"];
            break;
        case INTERFACE_TYPE_LOGIN:
            [self RequestWithParam:param withUrl:@"/user/login"];
            break;
        case INTERFACE_TYPE_ADDEQUIPMENT:
            [self RequestWithParam:param withUrl:@"/device/register"];
            break;
        case INTERFACE_TYPE_FORGETPWD:
            [self RequestWithParam:param withUrl:@"/user/forget"];
            break;
        case INTERFACE_TYPE_DEVICELIST:
            [self RequestWithParam:param withUrl:@"/device/list"];
            break;
        case INTERFACE_TYPE_RENAME:
            [self RequestWithParam:param withUrl:@"/device/edit"];
            break;
        case INTERFACE_TYPE_ADBOUTPRODUCT:
            [self RequestWithParam:param withUrl:@"/article/help"];
            break;
        case INTERFACE_TYPE_RETURNQUESTION:
            [self RequestWithParam:param withUrl:@"/article/feedback"];
            break;
        case INTERFACE_TYPE_CHARTDATE:
            [self RequestWithParam:param withUrl:@"/report/chart"];
            break;
        case INTERFACE_TYPE_LAMPSETTING:
            [self RequestWithParam:param withUrl:@"/device/getSetting"];
            break;
        case INTERFACE_TYPE_SETLAMP:
            [self RequestWithParam:param withUrl:@"/device/setting"];
            break;
        case INTERFACE_TYPE_DELETELAMP:
            [self RequestWithParam:param withUrl:@"/device/remove"];
            break;
        case INTERFACE_TYPE_FEEDBACK:
            [self RequestWithParam:param withUrl:@"/article/feedback"];
            break;
        case INTERFACE_TYPE_QIUT:
            [self RequestWithParam:param withUrl:@"/user/logout"];
            break;
        case INTERFACE_TYPE_OUTDOORWEATHER:
            [self RequestWithParam:param withUrl:@"/report/weather"];
            break;
        case INTERFACE_TYPE_ALARMCLOCKLIST:
            [self RequestWithParam:param withUrl:@"/alarmClock/list"];
            break;
        case INTERFACE_TYPE_ENVIRONMENTREPORT:
            [self RequestWithParam:param withUrl:@"/report/daily"];
            break;
        case INTERFACE_TYPE_OPENALARMCLOCK:
            [self RequestWithParam:param withUrl:@"/alarmClock/open"];
            break;
        case INTERFACE_TYPE_ADDALARMCLOCK:
            [self RequestWithParam:param withUrl:@"/alarmClock/add"];
            break;
        case INTERFACE_TYPE_MODIFYALARMCLOCK:
            [self RequestWithParam:param withUrl:@"/alarmClock/edit"];
            break;
        case INTERFACE_TYPE_REMOVEALARMCLOCK:
            [self RequestWithParam:param withUrl:@"/alarmClock/remove"];
            break;
    }
}

/**
 *  网络请求
 */
- (void) RequestWithParam:(NSDictionary *)param withUrl:(NSString *)url{
    
//    __block ZJInterface *weakself = self;
    AFHTTPSessionManager *manager = [self getAFHttpSessionManager];
    NSString *urlString = [URL stringByAppendingString:url];
    [manager POST:urlString parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        if ([responseObject[@"code"] isEqual:@(12007)] || [responseObject[@"code"] isEqual:@(10003)])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QUIT" object:nil];
        }
        if([_delegate respondsToSelector:@selector(interface:result:error:)])
        {
            [_delegate interface:self result:responseObject  error:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if([_delegate respondsToSelector:@selector(interface:result:error:)])
        {
            [_delegate interface:self result:nil  error:error];
        }
    }];
}

/**
 * 实例化AFHTTPSessionManager
 */
- (AFHTTPSessionManager *) getAFHttpSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager setResponseSerializer:responseSerializer];

    return manager;
}

@end
