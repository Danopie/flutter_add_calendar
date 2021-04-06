import Flutter
import UIKit
import EventKit

var channel: FlutterMethodChannel!
let sencondToMillisecond: Double = 1000.0

public class SwiftFlutterAddCalendarPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "flutter_add_calendar/native", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAddCalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
            case "setEventToCalendar":
                setCalendar(eventInfo: call.arguments as! Dictionary)
                break

            default:
                break
            }
  }
    
    func setCalendar(eventInfo: Dictionary<String, Any>) {
        let title: String = eventInfo["title"] as! String
        let desc: String = eventInfo["desc"] as! String
        let startTimestamp: Double = Double(eventInfo["startDate"] as! String)!
        let endTimestamp: Double = Double(eventInfo["endDate"] as! String)!
        let alertTime: Double = Double(eventInfo["alert"] as! String)!
        let location: String = eventInfo["location"] as! String
        let startDate = Date(timeIntervalSince1970: (startTimestamp > 0 ? (startTimestamp/sencondToMillisecond) : 0))
        let endDate = Date(timeIntervalSince1970: (endTimestamp > 0 ? (endTimestamp/sencondToMillisecond) : 0))
        let alertAt = alertTime/1000
        
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if(error == nil){
                if(granted){
                    let event = EKEvent(eventStore: eventStore)
                    event.title = title
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = desc
                    event.location = location
                    let alarmAdd = EKAlarm(relativeOffset: alertAt)
                    event.addAlarm(alarmAdd)
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let e as NSError {
                        //                    completion?(false, e)
                        channel.invokeMethod("receiveStatus", arguments: ["code": "\(e.code)", "message": e.localizedDescription])
                        return
                    }
                    channel.invokeMethod("receiveStatus", arguments: ["code": "1", "message": "Success"])
                }else{
                    let message = "Vui lòng thiết lập Cho phép Sendo truy cập vào Lịch. Vào Cài đặt > Ứng dụng > Sendo > Lịch"
                    let alertController = UIAlertController (title: "Sendo", message: message, preferredStyle: .alert)

                    let settingsAction = UIAlertAction(title: "Cài đặt", style: .default) { (_) -> Void in
                        self.openSettings()
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Thoát", style: .default, handler: nil)
                    alertController.addAction(cancelAction)

                    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)

                    channel.invokeMethod("receiveStatus", arguments: ["code": "-2", "message": message])
                }
            }else{
                channel.invokeMethod("receiveStatus", arguments: ["code": "-1", "message": error?.localizedDescription])
            }
        })
    }

    func openSettings() -> Void {
        if #available(iOS 10, *) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
    }
}
