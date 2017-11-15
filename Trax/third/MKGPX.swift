//
//  MKGPX.swift
//  Trax
//
//  Created by mac on 2017/11/14.
//  Copyright © 2017年 modi. All rights reserved.
//

import MapKit

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
}
