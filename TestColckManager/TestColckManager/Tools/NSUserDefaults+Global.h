//
//  NSUserDefaults+Global.h
//
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Global)

/**
 * @brief 儲存到 value 到 standardUserDefaults
 */
+ (void)saveOjbect:(id)value forKey:(NSString*)keyName;

/**
 * @brief 取出 standardUserDefaults object
 */
+ (id)loadObjectForKey:(NSString*)keyName;

/**
 * @brief 判斷是否有此 key
 */
+ (BOOL)hasKey:(NSString*)keyName;

/**
 * @brief 清除此 key, 包含物件
 */
+ (void)removeKey:(NSString*)keyName;

@end
