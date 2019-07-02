#import <FlutterMacOS/FlutterMacOS.h>

@interface UniLinksPlugin : NSObject <FlutterPlugin>
+ (instancetype)sharedInstance;
- (BOOL)application:(NSApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler;
@end
