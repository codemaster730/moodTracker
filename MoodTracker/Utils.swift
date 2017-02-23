//
//  Utils.swift
//  MoodTracker
//
//  Created by axiom88 04/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class Utils{
    
    let kImageSizeScaleRate = 0.1
    class func getImageMetaData(_ image: UIImage)->MTImage?{ // Get MetaData from Image
        
        
        return nil
    }
    
    class func getMetaDataFromAssetLibrary (_ info: NSDictionary)->MTImage?{
        
        /*
        let library = ALAssetsLibrary()
        var url: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        library.assetForURL(url, resultBlock: { (asset: ALAsset!) in
            
        }) { (error: NSError!) in
                print(error.localizedDescription)
        }
        */
        
        return nil
    }
    

    
    class func alertWithTitle(_ title: String, message: String) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    // MARK : File Manager
    
    class func getDocumentsDirectory()-> URL{
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    class func getTemporaryDirectory()-> String{
        
        return NSTemporaryDirectory()
    }
    
    class func saveImageToDirectory(image: Data){
        
        let fileName = getDocumentsDirectory().appendingPathComponent("user.png")
        try? image.write(to: fileName)
        
    }
}

// UIImage

extension UIImage {
    
    func imageWithColor(_ color: UIColor) -> UIImage {
    
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
