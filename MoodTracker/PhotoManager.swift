//
//  PhotoManager.swift
//  MoodTracker
//
//  Created by axiom88 10/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import Foundation
import Photos
import AFDateHelper
import RealmSwift

class PhotoManager {
    
    
    var savedList : Results<MTImage>!
    var newPhotosList: [MTImage]!
    var newPhotosWithFaceList: [MTImage]!
    var newPhotosWithUserFaceList: [MTImage]!
    var imageManager : PHCachingImageManager!
    
    class var sharedInstance: PhotoManager {
        
        struct Static {
            static let instance: PhotoManager = PhotoManager()
        }
        return Static.instance
    }
    
    init(){
        
        newPhotosList = []
        newPhotosWithFaceList = []
        newPhotosWithUserFaceList = []
    }
    
    func addNewPhotos(fetchedResult: PHFetchResult<PHAsset>, completion: @escaping (_ result: Bool) -> Void) {
        
        
        self.savedList = uiRealm.objects(MTImage.self)
        self.savedList = self.savedList.sorted(byProperty: "time", ascending: true)
        var latestPhoto = self.savedList.last
        if latestPhoto == nil{ // When open the app for the first time or doesn't have any saved photos
            print("No saved photos found")
            latestPhoto = MTImage()
            latestPhoto?.time = Date(timeIntervalSince1970: 0)
        }
        
        var tempList = [PHAsset]()
        for i in 0..<fetchedResult.count{
            
            let asset = fetchedResult[i]
            
            print("Creation date is \(asset.creationDate)")
            print("Last photo date is \(latestPhoto?.time)")
            
            if asset.mediaType == PHAssetMediaType.image{  // Check image or video or audio
                
                if (asset.creationDate?.isLaterThanDate((latestPhoto?.time)!)) == true, asset.creationDate?.isEqualToDateIgnoringTime((latestPhoto?.time)!) == false { // Check latest photo or not
                    
                      tempList.append(asset)
                }
            }
            
        }
        
        if tempList.count == 0 { // No New Photos
            
            completion(false)
        }
        
        for asset in tempList{
            
            let photo = MTImage()
            photo.latitude = 0.0
            photo.longitude = 0.0
            photo.time = asset.creationDate!
            
            PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { (data: Data?, str: String?, ori: UIImageOrientation, info: [AnyHashable : Any]?) in
                photo.image = data!
                self.newPhotosList.append(photo)
                if self.newPhotosList.count == tempList.count{
                    completion(true)
                }
            })
        }


        print("Total Photos - \(fetchedResult.count)")
        
    }
    
    func storeObject(object: MTImage) {

        do {
            try uiRealm.write({
                uiRealm.add(object, update: false)
                print(" Photo stored.")
            })
        }catch let error {
            print(error)
        }
    }
}
