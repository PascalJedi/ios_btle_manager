//
//  btleMgr.swift
//  btleManager
//
//  Created by Randal Erman on 3/10/19.
//  Copyright © 2019 Randal Erman. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol btleManagerDelegate {
    
    func DeviceListChanged()

}





class btleManager : NSObject {

    // Create Singleton
    static var shared : btleManager = btleManager()
    
    var centralManager : CBCentralManager!
    var m_discoveredPeripherals : [ btleDiscDev ] = []
    var m_arrConnectedDevices : [ btleDev ] =  []
    var m_arrPreConnectedCTDs :  [ AnyObject ] = []
    var m_arrTargetDevicesCBUUID :  [ AnyObject ] = [ ]

    var delegate : btleManagerDelegate? = nil
    
    func ConnectBluetoothDevice(peripheral : CBPeripheral) {
        
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        print("BLE did discover peripheral")
        
    }
    
    func DisconnectBluetoothDevice(peripheral : CBPeripheral) {
        
        
        centralManager.cancelPeripheralConnection(peripheral);
    
    }
    
    override init()
    {
        super.init()
        
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    
    func FindConnectedDevice(aPeripheral : CBPeripheral) -> btleDev?
    {
        for i in 0..<m_arrConnectedDevices.count
        {
            let dev = self.m_arrConnectedDevices[i]
            
            if (dev.btlePeriph != nil)
            {
                if (dev.btlePeriph == aPeripheral)
                {
                    return dev;
                }
            }
        }
        
        return nil
    }
    
    func FindConnectedDeviceByUUID(uuid : String) -> btleDev?
    {
        for i in 0..<m_arrConnectedDevices.count
        {
            let dev = self.m_arrConnectedDevices[i]
            
            if (dev.btlePeriph != nil)
            {
                if (dev.btlePeriph?.identifier.uuidString == uuid)
                {
                    return dev;
                }
            }
        }
        
        return nil
    }
    
    func startScanning()
    {
        // Put the Service UUID from the advertisement
        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning()
    {
        // Put the Service UUID from the advertisement
        self.centralManager?.stopScan()
    }
}


extension btleManager : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn{
            
            NotificationCenter.default.post(name: btleMgr_BluetoothOn, object: nil)
            
            central.scanForPeripherals(withServices: nil, options: nil)
            
            print("BLE Powered on")
            
        }
        
        if central.state == .poweredOff {
            
            NotificationCenter.default.post(name: btleMgr_BluetoothOff, object: nil)
            
            print("BLE Powered off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let dev : btleDev = FindConnectedDevice(aPeripheral: peripheral)
        {
            // We should update RSSI here?
            
            return;
        }
        
        for i in 0..<self.m_discoveredPeripherals.count
        {
            let searchedBLE : btleDiscDev  = self.m_discoveredPeripherals[i]
         
            // If this is the actual device, let's update the info
            // and reset the timer
            if (searchedBLE.btlePeriph == peripheral)
            {
                searchedBLE.RSSI = RSSI
                searchedBLE.timer?.invalidate()
                
                searchedBLE.timer = Timer(timeInterval: 5.0, target: self, selector: #selector(deviceTimeout), userInfo: searchedBLE, repeats: false)
                
                return
            }
        }
    
        // Check if it is our previous device list and connect automagically?
        // RRR
        
        
        // This is a brand new device
        // Let's create a new discovered element to track its
        // life cycle
        let BLED : btleDiscDev = btleDiscDev()
        
        BLED.btlePeriph = peripheral;
        BLED.advertisementData = advertisementData;
        BLED.RSSI = RSSI;
        BLED.timer = Timer(timeInterval: 5.0, target: self, selector: #selector(deviceTimeout), userInfo: BLED, repeats: false)
        
        self.m_discoveredPeripherals.append(BLED);
        
        delegate?.DeviceListChanged()
    }
        
    
    
    @objc func deviceTimeout(_ timer : Timer) {
    
        let BLED_UUID : btleDiscDev = timer.userInfo as! btleDiscDev
        
        for i in 0..<self.m_discoveredPeripherals.count
        {
            let searchedBLED : btleDiscDev = self.m_discoveredPeripherals[i]
            
            if (searchedBLED.btlePeriph == BLED_UUID.btlePeriph)
            {
                searchedBLED.timer?.invalidate()
                
                if let i = self.m_discoveredPeripherals.index(of: searchedBLED) {
                    self.m_discoveredPeripherals.remove(at: i)
                }
                
                self.delegate?.DeviceListChanged()
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        let dev : btleDev = btleDev(peripheral)
        dev.centralManager = self.centralManager
        
        self.m_arrConnectedDevices.append(dev)
        
        dev.discoverServices()
        
        print("BLE Device Connected did connect")

    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]){
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("Device lost connection");
        
        // Check to see if we have somehow already connected to this
        // device
        let dev = self.FindConnectedDevice(aPeripheral: peripheral) as btleDev?
        if (dev != nil)
        {
            // Log the disconnect event
            dev!.clearMemory()
            
            if let i = self.m_arrConnectedDevices.index(of: dev!) {
                self.m_arrConnectedDevices.remove(at: i)
            }
        }
        
        // Send notifications to multiple outlets
        NotificationCenter.default.post(name: btleMgr_DeviceDisconnected, object: nil)
        
        self.delegate?.DeviceListChanged()
    }
}
