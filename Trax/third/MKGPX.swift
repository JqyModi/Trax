//
//  MKGPX.swift
//  Trax
//
//  Created by mac on 2017/11/14.
//  Copyright © 2017年 modi. All rights reserved.
//

import MapKit
//创建子类扩展父类变量
class EditableWaypoint: GPX.Waypoint {
    override var coordinate: CLLocationCoordinate2D {
        get {
            return super.coordinate
        }
        set {
            coordinate.latitude = newValue.latitude
            coordinate.longitude = newValue.longitude
        }
    }
    
    var thumbnailURL1: NSURL? {
        return self.imageURL1
    }
    
    var imageURL1: NSURL? {
        return links.first?.url as! NSURL
    }
}

extension GPX.Waypoint: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var title: String! {
        return name
    }
    var subTitle: String! {
        return info
    }
    
    var thumbnailURL: NSURL? {
        return getImageURLOfType(type: "thumbnail")
    }
    
    var imageURL: NSURL? {
        return getImageURLOfType(type: "large")
    }
    
    func getImageURLOfType(type: String) -> NSURL? {
        if links.count > 0 {
            for link in links {
                if link.type == type {
                    return link.url as! NSURL
                }
            }
        }
        return nil
    }
}
