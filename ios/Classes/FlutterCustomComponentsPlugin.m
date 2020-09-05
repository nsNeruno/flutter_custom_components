#import "FlutterCustomComponentsPlugin.h"
#if __has_include(<flutter_custom_components/flutter_custom_components-Swift.h>)
#import <flutter_custom_components/flutter_custom_components-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_custom_components-Swift.h"
#endif

@implementation FlutterCustomComponentsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCustomComponentsPlugin registerWithRegistrar:registrar];
}
@end
