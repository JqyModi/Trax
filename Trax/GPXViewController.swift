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
            //设置模式为卫星地图
            //mapView.mapType = .satellite
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
    //长按添加标注视图
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        let state = sender.state
        if state == .began {
            //将长按点坐标转换到mapView上对应坐标
            let coordinate2D = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            //创建路点
            //let waypoint = GPX.Waypoint(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
            //替换为可拖动的标注
            let waypoint = EditableWaypoint(latitude: coordinate2D.latitude, longitude: coordinate2D.longitude)
            waypoint.name = "Dropped name"
            waypoint.info = "Dropped info"
            //添加测试图片
            waypoint.links.append(GPX.Link(href: "http://web.stanford.edu/class/cs193p/Images/Panorama.jpg"))
            //mapView上添加路点
            mapView.addAnnotation(waypoint)
        }
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
    static let DetailCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 49)
    static let AnnotationViewReuseIdentifier = "waypoint"
    static let ShowImageSegue = "Show Image"
    static let EditableWaypointSegue = "Show Editable"
    static let EditWaypointPopoverWidth: CGFloat = 320
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
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        view?.detailCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            //设置左视图
            if waypoint.thumbnailURL != nil {
                //初始化子Item时创建视图frame
                //view?.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
                view?.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            //设置右视图为详情按钮
            if annotation is EditableWaypoint {
                view?.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as? UIButton
            }
            //都需要显示详细信息
            view?.detailCalloutAccessoryView = UILabel(frame: Constants.DetailCalloutFrame)
        }
        
        //设置路点可拖拽：X is X = Bool
        view?.isDraggable = annotation is EditableWaypoint
        print("isDraggable = \(view?.isDraggable)")

        return view
    }
    //选择标注视图回调
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let waypoint = view.annotation as? GPX.Waypoint {
            if let editWaypoint = waypoint as? EditableWaypoint {
                //新版Swift不能重写扩展的变量
                if let url = editWaypoint.thumbnailURL1 {
                    if view.leftCalloutAccessoryView == nil {
                        view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
                    }
                    if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                        //选择视图时设置图片内容
                        DispatchQueue.global(qos: .userInitiated).async {
                            if let imageData = NSData(contentsOf: url as! URL) {
                                if let image = UIImage(data: imageData as Data) {
                                    DispatchQueue.main.async {
                                        thumbnailImageButton.setImage(image, for: .normal)
                                    }
                                }
                            }
                        }
                    }
                    if let detailLabel = view.detailCalloutAccessoryView as? UILabel {
                        detailLabel.text = waypoint.info
                    }
                }
            }
            if let url = waypoint.thumbnailURL {
                if view.leftCalloutAccessoryView == nil {
                    view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
                }
                if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                    //选择视图时设置图片内容
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = NSData(contentsOf: url as! URL) {
                            if let image = UIImage(data: imageData as Data) {
                                DispatchQueue.main.async {
                                    thumbnailImageButton.setImage(image, for: .normal)
                                }
                            }
                        }
                    }
                }
                if let detailLabel = view.detailCalloutAccessoryView as? UILabel {
                    detailLabel.text = waypoint.info
                }
            }
        }
    }
    //选择详情按钮回调
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.detailDisclosure {
            performSegue(withIdentifier: Constants.EditableWaypointSegue, sender: view)
            //取消标注视图选中状态
            mapView.deselectAnnotation(view.annotation, animated: true)
        }else if let waypoint = view.annotation as? GPX.Waypoint {
            //代码跳转Segue
            performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
        }
    }
    //准备跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier  {
            if identifier == Constants.ShowImageSegue {
                if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                    //为内嵌有EbmedViewController的控制器准备Segue
                    if let wivc = segue.destination.contentViewController as? WaypointImageViewController {
                        wivc.waypoint = waypoint
                    }else if let ivc = segue.destination as? ImageViewController {
                        ivc.imageURL = waypoint.imageURL
                        ivc.title = waypoint.name
                    }
                }
            }else if identifier == Constants.EditableWaypointSegue {
                if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditableWaypoint {
                    //带导航栏：contentViewController扩展UIViewController获取
                    if let evc = segue.destination.contentViewController as? EditWaypointViewController {
                        //判断是否是Popover方式跳转
                        if let ppc = evc.popoverPresentationController {
                            let coordinatePoint = mapView.convert(waypoint.coordinate, toPointTo: mapView)
                            ppc.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint: coordinatePoint)
                            //设置Popover的宽高包裹：UILayoutFittingCompressedSize | UILayoutFittingExpandedSize（尽量大）
                            let minSize = evc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                            evc.preferredContentSize = CGSize(width: Constants.EditWaypointPopoverWidth, height: minSize.height)
                            //添加popoverPresentationController代理事件
                            ppc.delegate = self
                        }
                        evc.waypointToEdit = waypoint
//                        evc.title = waypoint.name
                    }
                }
            }
        }
    }
    
    
}
extension GPXViewController: UIPopoverPresentationControllerDelegate {
    //设置Popover显示样式
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        //重新配置显示控制器
        let navCon = UINavigationController(rootViewController: controller.presentedViewController)
        //设置高斯模糊背景
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navCon.view.bounds
        navCon.view.insertSubview(visualEffectView, at: 0)
        return navCon
    }
}

//扩展UIViewController：当带导航栏是获取视图内容ViewController
extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController!
        }else {
            return self
        }
    }
}
//扩展获取当前标注的anchor部分
extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width/2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height/2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}

