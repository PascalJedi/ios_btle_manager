//
//  btleDiscDev.swift
//  btleManager
//
//  Created by Randal Erman on 3/10/19.
//  Copyright © 2019 Randal Erman. All rights reserved.
//

import Foundation
import CoreBluetooth

class btleDiscDev : NSObject {
    
    var btlePeriph : CBPeripheral? = nil
    var advertisementData : [String : Any] = [:];
    var RSSI : NSNumber = 0
    var timer : Timer?

    override init()
    {
        super.init()
    }
}
