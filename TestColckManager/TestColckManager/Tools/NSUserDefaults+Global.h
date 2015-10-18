//
//  NSUserDefaults+Global.h
//  O8App
//
//  Created by esp on 2015/5/19.
//  Copyright (c) 2015年 SGT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief 通用型的 user default 檔案 (standardUserDefaults).
 */
@interface NSUserDefaults (Global)

/** 儲存到 value 到 standardUserDefaults */
+ (void)global_SyncOjbect:(id)value forKey:(NSString*)keyName;

/** 取出 standardUserDefaults object */
+ (id)global_ObjectForKey:(NSString*)keyName;

/** 判斷是否有此 key */
+ (BOOL)global_HasKey:(NSString*)keyName;

/** 清除此 key, 包含物件 */
+ (void)global_RemoveKey:(NSString*)keyName;

@end
