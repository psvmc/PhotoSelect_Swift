//
//  ViewController.swift
//  PhotoSelect_Swift
//
//  Created by 张剑 on 16/1/23.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DNImagePickerControllerDelegate{

    @IBOutlet weak var filePathLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func photoSelectClick(sender: AnyObject) {
        let imagePicker = DNImagePickerController();
        imagePicker.imagePickerDelegate = self;
        imagePicker.navigationBarColor = UIColor.blackColor();
        self.presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    //图片选择组件
    func dnImagePickerController(imagePicker: DNImagePickerController!, sendImages imageAssets: [AnyObject]!, isFullImage fullImage: Bool) {
        
        var urls:[NSURL] = [];
        
        for obj in imageAssets{
            let dnasset = obj as! DNAsset;
            urls.append(dnasset.url);
        }
        
        ZJALAssetUtils.imagesWithURLs(urls) { (imageURLs) -> Void in
            var myimageURLs:[NSURL] = [];
            self.filePathLabel.text = "";
            for obj in imageURLs{
                let imageURL = obj as! NSURL;
                myimageURLs.append(imageURL);
                self.filePathLabel.text = self.filePathLabel.text! + "文件路径: \(imageURL.debugDescription)\n\n";
            }

            
        }
    }
    
    func dnImagePickerControllerDidCancel(imagePicker: DNImagePickerController!) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil);
    }

}

