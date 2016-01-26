//
//  ViewController.swift
//  PhotoSelect_Swift
//
//  Created by 张剑 on 16/1/23.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DNImagePickerControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var filePathLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        rightImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func photoSelectClick(sender: AnyObject) {
        self.filePathLabel.text = "";
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

        ZJALAssetUtils.aLAssetWithURL(urls[0]) { (asset) -> Void in
            if(asset != nil){
                let representation =  asset.defaultRepresentation()
                let image = UIImage(CGImage:representation.fullScreenImage().takeUnretainedValue())
                self.imageView.image = image;
            }
        }
        
        ZJALAssetUtils.imagesWithURLs(urls) { (imageURLs) -> Void in
            var myimageURLs:[NSURL] = [];
            var filePathText = "";
            self.filePathLabel.text = "";
            for obj in imageURLs{
                let imageURL = obj as! NSURL;
                myimageURLs.append(imageURL);
                filePathText += "文件路径: \(imageURL.path!)\n\n";
            }
            if(myimageURLs.count > 0){
                self.rightImageView.image = UIImage(contentsOfFile: myimageURLs[0].path!);
            }
            
            self.filePathLabel.text = filePathText; 
        }
    }
    
    func dnImagePickerControllerDidCancel(imagePicker: DNImagePickerController!) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil);
    }

}

