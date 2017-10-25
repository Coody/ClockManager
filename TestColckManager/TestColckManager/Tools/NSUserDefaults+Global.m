//
//  NSUserDefaults+Global.m
//
//

#import "NSUserDefaults+Global.h"

@implementation NSUserDefaults (Global)

// 儲存到 standardUserDefaults
+ (void)saveOjbect:(id)value forKey:(NSString*)keyName{
    [[self standardUserDefaults] setObject:value forKey:keyName];
    [[self standardUserDefaults] synchronize];
}

// 取出 standardUserDefaults object
+ (id)loadObjectForKey:(NSString*)keyName{
    return [[self standardUserDefaults] objectForKey:keyName];
}

// 判斷是否有此 key
+ (BOOL)hasKey:(NSString*)keyName{
    return ( [[self standardUserDefaults] objectForKey:keyName] != nil );
}

// 清除此 key, 包含物件
+ (void)removeKey:(NSString*)keyName{
    [[self standardUserDefaults] removeObjectForKey:keyName];
    [[self standardUserDefaults] synchronize];
}

@end
