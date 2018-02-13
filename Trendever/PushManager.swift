//
//  PushManager.swift
//  Trendever
//
//  Created by Roma Bakenbard on 29.08.16.
//  Copyright © 2016 Trendever. All rights reserved.
//

import Foundation

class PushManager: NSObject {
    
    var pushToken:String?
    var remoteNotification:NSDictionary?
    
    static let sharedInstance = PushManager()
    private override init() {}
    
    func setRemoteNotificationDic(dic:NSDictionary!) {
        remoteNotification = dic
        NSNotificationCenter.defaultCenter().postNotificationName("openURL", object: nil)
    }

}
