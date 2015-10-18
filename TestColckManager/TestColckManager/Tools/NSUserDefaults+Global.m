//
//  NSUserDefaults+Global.m
//  O8App
//
//  Created by esp on 2015/5/19.
//  Copyright (c) 2015年 SGT. All rights reserved.
//

#import "NSUserDefaults+Global.h"

@implementation NSUserDefaults (Global)

// 儲存到 standardUserDefaults.
+ (void)global_SyncOjbect:(id)value forKey:(NSString*)keyName
{
    [[self standardUserDefaults] setObject:value forKey:keyName];

    [[self standardUserDefaults] synchronize];
}

// 取出 standardUserDefaults object.
+ (id)global_ObjectForKey:(NSString*)keyName;
{
    return [[self standardUserDefaults] objectForKey:keyName];
}

// 判斷是否有此 key.
+ (BOOL)global_HasKey:(NSString*)keyName;
{
    return (nil != [[self standardUserDefaults] objectForKey:keyName]);
}

// 清除此 key, 包含物件.
+ (void)global_RemoveKey:(NSString*)keyName
{
    [[self standardUserDefaults] removeObjectForKey:keyName];

    [[self standardUserDefaults] synchronize];
}

@end
