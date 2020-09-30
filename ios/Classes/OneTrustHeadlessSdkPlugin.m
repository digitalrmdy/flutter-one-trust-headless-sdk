#import "OneTrustHeadlessSdkPlugin.h"
#if __has_include(<one_trust_headless_sdk/one_trust_headless_sdk-Swift.h>)
#import <one_trust_headless_sdk/one_trust_headless_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "one_trust_headless_sdk-Swift.h"
#endif

@implementation OneTrustHeadlessSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOneTrustHeadlessSdkPlugin registerWithRegistrar:registrar];
}
@end
