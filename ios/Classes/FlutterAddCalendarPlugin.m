#import "FlutterAddCalendarPlugin.h"
#import <flutter_add_calendar/flutter_add_calendar-Swift.h>

@implementation FlutterAddCalendarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAddCalendarPlugin registerWithRegistrar:registrar];
}
@end
