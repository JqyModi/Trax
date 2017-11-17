//
//  WaypointImageViewController.swift
//  Trax
//
//  Created by mac on 2017/11/17.
//  Copyright © 2017年 modi. All rights reserved.
//

import UIKit

class WaypointImageViewController: ImageViewController {

    //Model
    var waypoint: GPX.Waypoint? {
        didSet {
            //设置父类中的图片URL
           imageURL = waypoint?.imageURL
            //设置父类中Title
            title = waypoint?.name
            updateEmbeddedMap()
        }
    }
    
    var evc: EmbedViewController?
    
    private struct Constants {
        static let EmbedIdentifier = "Show Embed"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Constants.EmbedIdentifier {
                evc = segue.destination as! EmbedViewController
                updateEmbeddedMap()
            }
        }
    }
    
    //更新内嵌视图
    func updateEmbeddedMap() {
        if let mapView = evc?.mapView {
            //设置map类型:混合类型
            mapView.mapType = .hybrid
            //移除所有标注
            mapView.removeAnnotations(mapView.annotations)
            //添加新路点
            mapView.addAnnotation(waypoint!)
            //显示路点
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
}
