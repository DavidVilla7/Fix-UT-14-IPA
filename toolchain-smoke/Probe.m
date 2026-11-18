#import <Foundation/Foundation.h>

@interface FIFA14LinkerSmoke : NSObject
- (NSString *)status;
@end

@implementation FIFA14LinkerSmoke
- (NSString *)status {
    return @"armv7-ios-link-ok";
}
@end
