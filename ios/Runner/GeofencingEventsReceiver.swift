//
//  Woosmap.swift
//  MarketingConnector
//
//  Created by Woosmap on 08/10/24.
//

import Foundation
import WoosmapGeofencing

extension Notification.Name {
  static let updateRegions = Notification.Name("updateRegions")
  static let didEventPOIRegion = Notification.Name("didEventPOIRegion")
}

@objc(GeofencingEventsReceiver)
class GeofencingEventsReceiver: NSObject {
  @objc public func startReceivingEvent() {
    NotificationCenter.default.addObserver(self, selector: #selector(POIRegionReceivedNotification),
                                           name: .didEventPOIRegion,
                                           object: nil)
  }
  @objc func POIRegionReceivedNotification(notification: Notification) {
    if let POIregion = notification.userInfo?["Region"] as? Region{
      // YOUR CODE HERE
      if POIregion.didEnter {
        NSLog("didEnter")
        
        // if you want only push to batch geofence event related to POI,
        // check first if the POIregion.origin is equal to "POI"
        if POIregion.origin == "POI"
        {
          if let POI = POIs.getPOIbyIdStore(idstore: POIregion.identifier) as POI? {
            
            // Event with custom attributes
            //                        BatchProfile.trackEvent(name: "woos_geofence_entered_event", attributes: BatchEventAttributes { data in
            //                          // Custom attribute
            //                          data.put(POI.idstore ?? "", forKey: "identifier")
            //                          // Compatibility reserved key
            //                          data.put(POI.name ?? "", forKey: "name")
            //                        })
          }
          else {
            // error: Related POI doesn't exist
          }
        }
      }
      //executeNotification(region: POIregion )
    }
  }
  // Stop receiving notification
  @objc public func stopReceivingEvent() {
    NotificationCenter.default.removeObserver(self, name: .didEventPOIRegion, object: nil)
  }
  
  // Test background event with notification
  private func executeNotification(region: Region){
    Task {
      let content = UNMutableNotificationContent()
      
      if let moreInfo = POIs.getPOIbyIdStore(idstore: region.identifier){
        content.body += "\(region.didEnter ? "Entered Region" : "Exited Region") \(moreInfo.name ?? "-")"
      }
      else{
        if region.didEnter {
          content.title = "Exited Region \(region.identifier)"
          content.body = "please come back"
        }
        else{
          content.title = "Entered Region \(region.identifier)"
          content.body = "Welcome here"
        }
      }
      
      let uuidString = UUID().uuidString
      let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
      
      // Schedule the request with the system.
      let notificationCenter = UNUserNotificationCenter.current()
      do {
        try await notificationCenter.add(request)
      } catch {
        // Handle errors that may occur during add.
      }
    }
  }
}

