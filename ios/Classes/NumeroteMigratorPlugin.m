#import "NumeroteMigratorPlugin.h"
#if __has_include(<numerote_migrator/numerote_migrator-Swift.h>)
#import <numerote_migrator/numerote_migrator-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "numerote_migrator-Swift.h"
#endif

@implementation NumeroteMigratorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNumeroteMigratorPlugin registerWithRegistrar:registrar];
}
@end
