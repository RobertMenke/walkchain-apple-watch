//
//  InterfaceController.swift
//  walkchain WatchKit Extension
//
//  Created by Robert B. Menke on 6/24/18.
//  Copyright © 2018 Robert. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class InterfaceController: WKInterfaceController {

    //======================
    // IB Outlets
    //======================
    @IBOutlet var stepsLabel: WKInterfaceLabel!
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    
    //======================
    // Instance variables
    //======================
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var isSubscribedToActivity = false
    var isSubscribedToPedometer = false
    
    //======================
    // Lifecycle methods
    //======================
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        print("Will activate called")
        if !isSubscribedToActivity {
            startActivityListener()
        }
        
        if !isSubscribedToPedometer {
            startPedometerListener()
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        pedometer.stopUpdates()
        //TODO: Send update to server or background processing queue
    }
    
    //======================
    // Activity Events
    //======================
    private func startActivityListener() {
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity : CMMotionActivity?) in
            print("Activity update triggered")
            guard let activity = activity else { return }
        
            if activity.stationary {
                print("stationary")
            }
            if activity.walking {
                print("walking")
            }
            if activity.running {
                print("running")
            }
            if activity.automotive {
                print("driving")
            }
        }
        
        isSubscribedToActivity = true
    }
    
    //======================
    // Pedometer Events
    //======================
    private func startPedometerListener() {
        if CMPedometer.isPedometerEventTrackingAvailable() {
            print("Starting to listen to pedometer updates")
            pedometer.startUpdates(from: Date()) { (data, err) in
                print("Update sent")
                if err != nil {
                    print("There was an error requesting data from the pedometer: \(err!)")
                }
                
                if let data = data {
                    print("HERE")
                    self.updateSteps(data: data)
                    self.updateDistance(data: data)
                }
            }
            isSubscribedToPedometer = true
        }
    }
    
    //======================
    // UI Updates
    //======================
    private func updateSteps(data : CMPedometerData) {
        //We always want a whole, positive number of steps
        let steps = data.numberOfSteps.uintValue
        stepsLabel.setText(String(format: "%lu Steps", steps))
    }
    
    private func updateDistance(data : CMPedometerData){
        //Distance is in meters
        if let distance = data.distance {
            let milesWalked = metersToMiles(meters: distance as! Double)
            distanceLabel.setText(String(format: "%.2f Miles", milesWalked))
        }
    }
    
    private func metersToMiles(meters : Double) -> Double {
        return meters / 1609.344
    }
}
