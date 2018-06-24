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
    let pedometer = CMPedometer()
    
    //======================
    // Lifecycle methods
    //======================
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        createPedometerListener()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        pedometer.stopUpdates()
        //TODO: Send update to server or background processing queue
    }
    
    //======================
    // Pedometer Events
    //======================
    private func createPedometerListener() {
        if CMPedometer.isPaceAvailable() {
            pedometer.startUpdates(from: Date()) { (data, err) in
                if let data = data {
                    self.updateSteps(data: data)
                    self.updateDistance(data: data)
                }
            }
        }
    }
    
    private func updateSteps(data : CMPedometerData) {
        //We always want a whole, positive number of steps
        let steps = data.numberOfSteps.uintValue
        stepsLabel.setText(String(format: "%lu Steps", steps))
    }
    
    private func updateDistance(data : CMPedometerData){
        //Distance is in meters
        if let distance = data.distance {
            let milesWalked = metersToMiles(meters: distance)
            distanceLabel.setText(String(format: "%.2f Miles", milesWalked))
        }
    }
    
    private func metersToMiles(meters : NSNumber) -> Double {
        return meters as! Double / 1609.344
    }
}
