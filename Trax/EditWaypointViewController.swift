//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by mac on 2017/11/16.
//  Copyright © 2017年 modi. All rights reserved.
//

import UIKit
//导入相机相关库
import MobileCoreServices

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var infoTextField: UITextField! {
        didSet {
            infoTextField?.delegate = self
        }
    }
    
    //Model
    var waypointToEdit: EditableWaypoint? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI(){
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
        //设置图片
        updateImage()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //取消第一响应：键盘消失
        infoTextField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        //关闭视图
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //添加通知监听
        observeTextFields()
    }
    //相当于一个cookie
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    func observeTextFields(){
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        ntfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nameTextField, queue: queue) { (notification) in
            if let waypoint = self.waypointToEdit {
                waypoint.name = self.nameTextField.text
            }
        }
        itfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: infoTextField, queue: queue) { (notification) in
            if let waypoint = self.waypointToEdit {
                waypoint.info = self.infoTextField.text
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //移除通知监听
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = itfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    //处理图片
    var imageView = UIImageView()
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            //用UIView来存放ImageView方便控制ImageView大小
            imageViewContainer.addSubview(imageView)
        }
    }
    
    //处理拍照
    @IBAction func takePhoto() {
        //判断相机是否可用
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            //设置媒体类型：视频或者图片等
            picker.mediaTypes = [kUTTypeImage as String]
            //设置可编辑
            picker.allowsEditing = true
            picker.delegate = self
            //打开相机
            present(picker, animated: true, completion: nil)
        }
    }
}
extension EditWaypointViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func updateImage(){
        if let url = self.waypointToEdit?.imageURL1 {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in //防止指针自身引用
                if let imageData = NSData(contentsOf: url as URL) {
                    if let image = UIImage(data: imageData as Data) {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                            //调整image大小
                            self?.makeRoomForImage()
                        }
                    }
                }
            }
        }
    }
    
    func makeRoomForImage(){
        var extraHeight: CGFloat = 0
        if (imageView.image?.aspectRatio)! > CGFloat(0) {
            if let width = imageView.superview?.frame.size.width {
                let height = width / (imageView.image?.aspectRatio)!
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        }else{
            extraHeight = -imageView.frame.height
            imageView.frame = CGRect.zero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
    
    //MARK: -TakePhoto
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //获取相机拍下的图片
        //首先获取可编辑图片
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        if image == nil {
            //无可用编辑图片则获取原始图片
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        //设置图片到UI
        imageView.image = image
        makeRoomForImage()
        //将照片保存到沙盒
        saveImageInWaypoint()
        //关闭相机
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //将照片保存到沙盒中
    func saveImageInWaypoint() {
        //获取到要保存的图片
        if let image = imageView.image {
            //获取图片Data类型数据：格式JPEG 压缩比1.0
            if let imageData = UIImageJPEGRepresentation(image, 1.0) as? NSData {
                //获取文件管理器
                let fileManager = FileManager.default
                //获取到Document路径
                if let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as? NSURL {
                    //获取当前作为图片名
                    let unique = NSDate.timeIntervalSinceReferenceDate
                    //拼接名称
                    let imageUrl = url.appendingPathComponent("\(unique).jpg")
                    if let path = imageUrl?.absoluteString {
                        //通过Data提供的方法写入数据:atomically代表复制副本完整拷贝
                        if imageData.write(to: imageUrl!, atomically: true) {
                            //设置图片到标注视图
                            self.waypointToEdit?.links = [GPX.Link(href: path)]
                        }
                    }
                }
            }
        }
    }
    
}
extension UIImage {
    //获取宽高比
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}
