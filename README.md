
Requirements
------------
- iOS 12.0+
- Xcode 10.1+
- Swift 4.2+

Getting Started
---------------
1. Open `Geofence.xcworkspace` with Xcode because it uses `Cocoapods`. All the dependencies (Pod folders) have already commited so you don't have to do `pod install`. 
2. The default scheme is configured to simulate a movement between two coordinates, Kuala Lumpur and Petaling Jaya.
3. Build and run with simulator, the app should be launched with a Location permission dialog.
4. After accepting `Always` or `When in Use`, you should be able to see the location is moving between two waypoints.
5. Enter some text in `SSID` and `Radius`, and tap the `Add` button to add a pin and overlay. For simplicity the `Add` action just takes the Map's center coordinates.
6. At this moment the geofence monitoring is already started. You can drag the pin and move around the map i.e. place it along the waypoints.
7. The view controller's title changes status to `inside` or `outside` whenever the current location enters/leaves the region.
8. You can change the `SSID` or `Radius` anytime and tap the `Update` button, the monitoring will stop and starts with the new changes.
9. If you relaunch the app, previously saved region will be loaded.
10. The monitoring will stop when you tap the `delete` button.
11. There are a few Unit Test written for Model and View Model, you can run them too.

Caveat
-------
1. The Wifi SSID matching can't be tested because in iOS 12 you need to enable the `Access Wifi Information` feature. It will add an entitlement to the project and allow the function call `CNCopyCurrentNetworkInfo` to work properly. Without that the function simply returns nil.
2. I don't have Apple Developer account so unable to  perform the step above.
3. I also don't own a Macbook or iPhone so this assignment is only tested on Xcode simulator running on a MacOS virtual machine on a Windows PC.
