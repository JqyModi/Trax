//
//  ViewController.swift
//  Trax
//
//  Created by mac on 2017/11/10.
//  Copyright © 2017年 modi. All rights reserved.
//

import UIKit
//导入MapKit
import MapKit

class GPXViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    var gpxURL: URL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url) {
                    if let gpx = $0 {
                        //模拟点位
                        //22.8900925348,113.8829040527
                        //22.8970506705,113.8568115234
//                        gpx.waypoints = [GPX.Waypoint.init(latitude: 22.8900925348, longitude: 113.8829040527),GPX.Waypoint.init(latitude: 22.8970506705, longitude: 113.8568115234)]
                        self.handleWaypoints(waypoints: gpx.waypoints)
                        print("waypoints = \(gpx.waypoints)")
                    }
                }
            }
        }
    }
    
    func clearWaypoints() {
        if mapView.annotations != nil {
            mapView.removeAnnotations(mapView.annotations as [MKAnnotation])
        }
    }
    
    private func handleWaypoints(waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //接收广播并处理
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        //获取全局Application代理
        let appDelegate = UIApplication.shared.delegate
        
        center.addObserver(forName: NSNotification.Name(rawValue: GPXURL.Notification), object: appDelegate, queue: queue) { (notification) in
            if let url = notification.userInfo?[GPXURL.Key] as? URL {
                self.gpxURL = url
            }
        }
        self.gpxURL = URL(string: "http://web.stanford.edu/class/cs193p/Vacation.gpx")
    }
}
private struct Constants {
    static let PartialTrackColor = UIColor.green
    static let FullTrackColor = UIColor.blue.withAlphaComponent(0.5)
    static let TrackLineWidth: CGFloat = 0.3
    static let ZoomCooldown = 1.5
    static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
    static let AnnotationViewReuseIdentifier = "waypoint"
    static let ShowImageSegue = "Show Image"
}
extension GPXViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //跟表格视图类似
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            //显示标注视图
            view?.canShowCallout = true
        }else{
            //复用时替换标注视图
            view?.annotation = annotation
        }
        return view
    }
}
