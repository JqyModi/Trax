//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by mac on 2017/11/16.
//  Copyright © 2017年 modi. All rights reserved.
//

import UIKit

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

}
