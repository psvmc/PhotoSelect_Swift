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
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        rightImageView.contentMode = UIViewContentMode.scaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func photoSelectClick(_ sender: AnyObject) {
        self.filePathLabel.text = "";
        let imagePicker = DNImagePickerController();
        imagePicker.imagePickerDelegate = self;
        imagePicker.navigationBarColor = UIColor.black;
        self.present(imagePicker, animated: true, completion: nil);
    }
    
    //图片选择组件
    private func dnImagePickerController(_ imagePicker: DNImagePickerController!, sendImages imageAssets: [AnyObject]!, isFullImage fullImage: Bool) {
        
        var urls:[URL] = [];
        
        for obj in imageAssets{
            let dnasset = obj as! DNAsset;
            urls.append(dnasset.url);
        }

        ZJALAssetUtils.aLAsset(with: urls[0]) { (asset) -> Void in
            if(asset != nil){
                let representation =  asset?.defaultRepresentation()
                let image = UIImage(cgImage:(representation?.fullScreenImage().takeUnretainedValue())!)
                self.imageView.image = image;
            }
        }
        
        ZJALAssetUtils.images(withURLs: urls) { (imageURLs) -> Void in
            var myimageURLs:[URL] = [];
            var filePathText = "";
            self.filePathLabel.text = "";
            for obj in imageURLs!{
                let imageURL = obj as! URL;
                myimageURLs.append(imageURL);
                filePathText += "文件路径: \(imageURL.path)\n\n";
            }
            if(myimageURLs.count > 0){
                self.rightImageView.image = UIImage(contentsOfFile: myimageURLs[0].path);
            }
            
            self.filePathLabel.text = filePathText; 
        }
    }
    
    func dnImagePickerControllerDidCancel(_ imagePicker: DNImagePickerController!) {
        imagePicker.dismiss(animated: true, completion: nil);
    }

}

