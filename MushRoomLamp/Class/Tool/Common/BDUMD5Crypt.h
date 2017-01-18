//
//  BDUMD5Crypt.h
//  MushRoomLamp
//
//  Created by SongGang on 7/7/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDUMD5Crypt : NSObject
+ (NSString *)HMACMD5WithString:(NSString *)toEncryptStr WithKey:(NSString *)keyStr;
@end