//
//  CameraViewController.swift
//  tkk
//
//  Created by Hasan Saral on 10.09.2019.
//  Copyright © 2019 Hasan. All rights reserved.
//

import UIKit


class CameraViewController: UIViewController, UITabBarControllerDelegate {

    @IBOutlet weak var dontAction: UIButton!
    @IBOutlet weak var useCamera: UIButton!
    @IBOutlet weak var cameraImage: UIImageView!
    
    let vc = UIImagePickerController()
    var rippleLayer : RippleLayer!
    var rippleFlag: Bool = false
    var sendFlag: Bool = false
    var imageData: UIImage? = nil
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useCamera.layer.borderWidth = 2
        useCamera.layer.cornerRadius = useCamera.frame.height / 2
        useCamera.clipsToBounds = true
        
        cameraImage.layer.cornerRadius = 10
        cameraImage.clipsToBounds = true
        
        dontAction.isHidden = true
       
       
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear is running")
       
        if rippleFlag {
            dontAction.isHidden = false
            rippleLayer = RippleLayer()
            rippleLayer.position = CGPoint(x: self.useCamera.layer.bounds.midX, y: self.useCamera.layer.bounds.midY);
            self.useCamera.layer.addSublayer(rippleLayer)
            rippleLayer.startAnimation()
            
    }
}

    @IBAction func useCameraAction(_ sender: Any) {
        
        if  sendFlag == false {
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            present(vc, animated: true)
            
        } else {
            
            let navController = self.tabBarController!.viewControllers![0] as! UINavigationController
            let vc = navController.topViewController as! ViewController
            vc.getImage(image: cameraImage.image!)
        
            dontAction.isHidden = true
            rippleFlag = false
            sendFlag = false
            rippleLayer.stopAnimation()
            cameraImage.image = nil
            useCamera.setTitle("Fotoğraf Çek", for: .normal)
            tabBarController?.selectedIndex = 0
        }
       
}
    
    @IBAction func noAction(_ sender: Any) {
        
        dontAction.isHidden = true
        rippleFlag = false
        sendFlag = false
        rippleLayer.stopAnimation()
        cameraImage.image = nil
        useCamera.setTitle("Fotoğraf Çek", for: .normal)
        
    }
 
    
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        
        rippleFlag = true
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
      
        sendFlag = true
        cameraImage.image = image
        useCamera.setTitle("Fotoğrafı Kullan", for: .normal)
        
    }
    
}
