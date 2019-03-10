//
//  btleDev.swift
//  btleManager
//
//  Created by Randal Erman on 3/10/19.
//  Copyright © 2019 Randal Erman. All rights reserved.
//

import Foundation
import CoreBluetooth

class btleDev : NSObject {
    
    // Notice to the controller and the device instance of BT Core
    var btlePeriph: CBPeripheral!
    var centralManager : CBCentralManager?
    
    init(_ bt: CBPeripheral) {
        super.init()
        
        btlePeriph = bt
        btlePeriph.delegate = self
    }
    
    func discoverServices()
    {
        btlePeriph.discoverServices(nil)
    }
    
    func clearMemory()
    {
        // Do any cleanup on disconnect
    }
}


extension btleDev : CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if (error != nil)
        {
            print(error!.localizedDescription)
            return
        }
        
        // loop through the services list
        if let serviceList = peripheral.services
        {
            for service in serviceList
            {
                peripheral.discoverCharacteristics(nil, for: service)
            }

            print(peripheral.services!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics!{
            
            switch characteristic.uuid {
                
            //case BLE.Testing.dailyVolumeId:
            //     BLE.Testing.dailyVolume = characteristic
            //    bottle?.readValue(for: BLE.Testing.dailyVolume!)
                
           
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        switch characteristic.uuid {
       
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didWriteValueFor")
       
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        
    }
    
    
}
