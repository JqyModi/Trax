//
//  ViewController.swift
//  Cassini
//
//  Created by mac on 2017/11/7.
//  Copyright © 2017年 modi. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    //model
    var imageURL: NSURL? {
        didSet {
            image = nil
            //判断当前界面是否处于显示状态
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    /*
     耗时操作需要多线程中
     */
    func fetchImage(){
        if let url = imageURL {
            //获取队列优先级
//            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            indicatorView.startAnimating()
            DispatchQueue.global().async(group: nil, qos: .userInitiated, flags: DispatchWorkItemFlags.enforceQoS, execute: {
                if let imageData = NSData(contentsOf: url.absoluteURL!) {
                    //更新主线程UI
                    DispatchQueue.main.async(execute: {
                        if imageData != nil {
                            self.image = UIImage(data: imageData as Data)
                        }else{
                            self.image = nil
                        }
                    })
                }
            })
        }
    }
    
    //view
    private var imageView = UIImageView()
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            //适配屏幕
            imageView.sizeToFit()
            //当图片被改变时也需要设置ScrollView的ContentSize：scrollView设置为可选的，因为第一次进入可能没有初始化
            scrollView?.contentSize = imageView.frame.size
            //设置图片完成隐藏indicator：用可选类型防止为nil情况
            indicatorView?.stopAnimating()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            //设置ScrollView的contentSize：否则无效
            scrollView.contentSize = imageView.frame.size
            //支持缩放
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        //通过segue来跳转
//        if image == nil {
//            imageURL = NSURL(string: Demo_URL.URL1)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //当前界面没有显示时被人设置了imageURL那么当界面出现时马上下载图片
        if  image == nil {
            fetchImage()
        }
    }
}
//扩展实现UIScrollView的缩放方法
extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

