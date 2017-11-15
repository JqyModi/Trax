//
//  AppDelegate.swift
//  Trax
//
//  Created by mac on 2017/11/10.
//  Copyright © 2017年 modi. All rights reserved.
//

import UIKit

//全局GPXURL
struct GPXURL {
    static let Notification = "GPX Notification"
    static let Key = "GPX UserInfo Key"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //接收一个文件时调用
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("url = \(url)")
        //通过广播发送一个消息给ViewController：附带URL
        let center = NotificationCenter.default
        center.post(name: NSNotification.Name(rawValue: GPXURL.Notification), object: self, userInfo: [GPXURL.Key : url])
        return true
    }
}

