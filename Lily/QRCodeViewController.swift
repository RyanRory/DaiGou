//
//  QRCodeViewController.swift
//  Lily
//
//  Created by 赵润声 on 3/2/18.
//  Copyright © 2018 Lily. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var button8: UIButton!
    @IBOutlet var button18: UIButton!
    @IBOutlet var saveImageButton: UIButton!
    var uuid = ""
    var couponImage:UIImage? = nil
    var params:NSMutableDictionary = ["used": false,
                                      "expired": false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.button8.tag = 1
        self.button18.tag = 2
        self.button8.addTarget(self, action: #selector(createImage), for: UIControlEvents.touchUpInside)
        self.button18.addTarget(self, action: #selector(createImage), for: UIControlEvents.touchUpInside)
        self.saveImageButton.addTarget(self, action: #selector(saveImage), for: UIControlEvents.touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func createQRForString(qrString: String?, qrImageName: String?) -> UIImage?{
        if let sureQRString = qrString {
            let stringData = sureQRString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            // 创建一个二维码的滤镜
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            qrFilter?.setValue(stringData, forKey: "inputMessage")
            qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
            let qrCIImage = qrFilter?.outputImage
            // 创建一个颜色滤镜,黑白色
            let colorFilter = CIFilter(name: "CIFalseColor")
            colorFilter?.setDefaults()
            colorFilter?.setValue(qrCIImage, forKey: "inputImage")
            colorFilter?.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter?.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            // 返回二维码image
            let codeImage = UIImage.init(ciImage: (colorFilter?.outputImage?.transformed(by: CGAffineTransform(scaleX: 5, y: 5)))!)
            return codeImage
        }
        return nil
    }
    
    // 1.把两张图片绘制成一张图片
    private func combine(leftImage: UIImage, rightImage: UIImage) -> UIImage {
        
        // 1.1.获取第一张图片的宽度
        let width = leftImage.size.width
        // 1.2.获取第一张图片的高度
        let height = leftImage.size.height
        
        // 1.3.开始绘制图片的大小
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        // 1.4.绘制第一张图片的起始点
        leftImage.draw(at: CGPoint(x: 0, y: 0))
        // 1.5.绘制第二章图片的起始点
        rightImage.draw(at: CGPoint(x: 30, y:(leftImage.size.height-rightImage.size.height)/2 ))
        
        // 1.6.获取已经绘制好的
        let imageLong = UIGraphicsGetImageFromCurrentImageContext()
        // 1.7.结束绘制
        UIGraphicsEndImageContext()
        
        // 1.8.返回已经绘制好的图片
        return imageLong!
    }
    
    @objc func createImage(_ sender: UIButton) {
        self.uuid = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        var background: UIImage? = nil
        
        if sender.tag == 1 {
            background = UIImage.init(named: "100-8")
            self.params["content"] = "100-8"
        }
        else {
            background = UIImage.init(named: "100-18")
            self.params["content"] = "100-18"
        }
        
        let QRImage = createQRForString(qrString: self.uuid, qrImageName: self.uuid)
        
        self.couponImage = combine(leftImage: background!, rightImage: QRImage!)
        
        self.imageView.image = self.couponImage
        
        self.params["uuid"] = self.uuid
        
        
    }
    
    @objc func saveImage(_ sender: AnyObject) {
        let image = self.imageView.image!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateTime = dateFormatter.date(from: "2018-04-30 23:59:59")
        
        self.params["deadline"] = dateTime
        
        SaveData.save(entityName: "Coupons", params: self.params as NSDictionary)
        
    }

}
