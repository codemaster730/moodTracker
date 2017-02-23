//
//  ViewController.swift
//  MoodTracker
//
//  Created by axiom88 04/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import UIKit
import MBProgressHUD
import Photos

class MTHomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var assetsFetchResults : PHFetchResult<PHAsset>!
    var _assetsCollection: PHAssetCollection!
    var assetsCollection: PHAssetCollection {
        get {
            return _assetsCollection
        }
        set (value) {
            _assetsCollection = value
            
            if _assetsCollection != nil {
                self.loadAssets()
            }
        }
    }
    
    @IBOutlet weak var portraitView: UIImageView!
    var isFromPicker : Bool = false  // fovariewdidappear() function, determine if this is called after picker disappear or not
    var userFace : Face?
    var loadingNotification : MBProgressHUD? = nil
    var detectedCount : Int = 0
    
    func initUI(){
        
        //crete circular profile picture
        self.portraitView.setNeedsLayout()
        self.portraitView.layoutIfNeeded()
        self.portraitView.layer.cornerRadius = self.portraitView.frame.width/2
        self.portraitView.clipsToBounds = true
        self.portraitView.layer.borderWidth = 2.0
        self.portraitView.layer.borderColor = UIColor.white.cgColor
        self.portraitView.layer.masksToBounds = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Import new photos
        
        self.requestPhotoAuthorization { (granted : Bool) in
            if granted == true {
                self.loadAssets()
            } else {
                let alertController = UIAlertController(title: "Photo Library Unavailable", message: "Please check to see if device settings doesn't allow photo library access", preferredStyle: UIAlertControllerStyle.alert)
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                    
                })
                let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                    let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsURL as! URL, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(settingsURL as! URL)
                    }
                })
                alertController.addAction(cancel)
                alertController.addAction(settings)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openPhotoCameraButton(_ sender: AnyObject) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType  = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        else{
            print("Camera Not Available")
        }
    }
    
    @IBAction func openPhotoLibraryButton(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            
            print("Library Not Available")
        }
        
    }
    
    // MARK : ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        isFromPicker = true
        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let resizedImage = tempImage.resize(toSize: CGSize(width:300,height:400), contentMode: UIImageContentMode.scaleAspectFit)
        
        picker.dismiss(animated: true) {
            
            self.detectUserFace(image: resizedImage!)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true) {
            let alert = Utils.alertWithTitle("Warning!", message: "Please take a photo to optimize the app's feature maximized")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        
    }
    
    // MARK : Face Detect
    
    func detectUserFace(image: UIImage){
        
        loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.label.text = "Detecting your face"
        loadingNotification?.show(animated: true)
        
        FaceAPI.detectFaces(image) { (result: FaceAPIResult<AnyObject, Error>) in
            
            DispatchQueue.main.sync(execute: {
                self.loadingNotification?.hide(animated: true)
                self.portraitView.image = image
                switch result {
                case .success(let json):
                    
                    var faces = [Face]()
                    let detectedFaces = json as! JSONArray
                    for item in detectedFaces {
                        
                        let face = item as! JSONDictionary
                        let faceId = face["faceId"] as! String   // Face Id
                        let rectangle = face["faceRectangle"] as! [String: AnyObject]  // Face Rectange
                        let attribute = face["faceAttributes"] as! [String: AnyObject]
                        let detectedFace = Face()
                        detectedFace.faceId = faceId
                        detectedFace.height = rectangle["top"] as! Int
                        detectedFace.width = rectangle["width"] as! Int
                        detectedFace.top = rectangle["top"] as! Int
                        detectedFace.left = rectangle["left"] as! Int
                        detectedFace.age = attribute["age"] as! Double
                        detectedFace.gender = attribute["gender"] as! String
                        detectedFace.smile = attribute["smile"] as! Double
                        
                        faces.append(detectedFace)
                    }
                    if faces.count == 0 {
                        
                        self.present(Utils.alertWithTitle("Error", message: "No face is detected, please choose correct one."), animated: true, completion: nil)
                    }
                    else if faces.count > 1 {
                        
                        self.present(Utils.alertWithTitle("Error", message: "You're supposed to take a picture of your own, please choose correct one."), animated: true, completion: nil)
                    }
                    else {
                        
                        self.userFace = faces.first!
//                        let strMsg = "Age: \(self.userFace?.age) \nGender: \(self.userFace?.gender) \nConfidence: \(self.userFace?.smile)"
//                        self.present(Utils.alertWithTitle("Face detected", message: strMsg), animated: true, completion: nil)
                        // Save user's photo
                        DispatchQueue.global().async {
                            
                            if let userImgData = UIImagePNGRepresentation(image){
                                let filename = Utils.getTemporaryDirectory().appending("user.png")
                                try? userImgData.write(to: URL(fileURLWithPath: filename))
                            }
                        }
                        
                        // Detect Other Photo's Face
                        self.loadingNotification?.label.text = "Detecting faces of photos in Gallery"
                        self.loadingNotification?.show(animated: true)
                        print("Total New Photo :  \(PhotoManager.sharedInstance.newPhotosList.count)")
                        for i in 0..<PhotoManager.sharedInstance.newPhotosList.count{
                            let photo = PhotoManager.sharedInstance.newPhotosList[i]
                            
                            let tempImage = UIImage(data: photo.image, scale: 1.0)
                            let resizedImage = tempImage?.resize(toSize: CGSize(width:300,height:400), contentMode: UIImageContentMode.scaleAspectFit)
                            self.detectFaces(image: resizedImage!,index: i)
                            
                        }
                    }
                    break
                case .failure(let error):
                    self.loadingNotification?.hide(animated: true)
                    print("DetectFaces error - ", error)
                    self.present(Utils.alertWithTitle("Error", message: error.localizedDescription), animated: true, completion: {
                    })
                    break
                }
            })
        }
    }
    
    func detectFaces(image: UIImage, index: Int){
        
        FaceAPI.detectFaces(image) { (result: FaceAPIResult<AnyObject, Error>) in
            
            DispatchQueue.main.sync(execute: {
                
                switch result {
                case .success(let json):

                    let photo = PhotoManager.sharedInstance.newPhotosList[index]
                    let detectedFaces = json as! JSONArray
                    for item in detectedFaces { // Detect only faces , non-face pictures will be ignored.
                        
                        let face = item as! JSONDictionary
                        let faceId = face["faceId"] as! String   // Face Id
                        let rectangle = face["faceRectangle"] as! [String: AnyObject]  // Face Rectange
                        let attribute = face["faceAttributes"] as! [String: AnyObject]
                        let detectedFace = Face()
                        detectedFace.faceId = faceId
                        detectedFace.height = rectangle["top"] as! Int
                        detectedFace.width = rectangle["width"] as! Int
                        detectedFace.top = rectangle["top"] as! Int
                        detectedFace.left = rectangle["left"] as! Int
                        detectedFace.age = attribute["age"] as! Double
                        detectedFace.gender = attribute["gender"] as! String
                        detectedFace.smile = attribute["smile"] as! Double
                        
                        photo.faces.append(detectedFace)
//                        PhotoManager.sharedInstance.storeObject(object: photo)
                        PhotoManager.sharedInstance.newPhotosWithFaceList.append(photo)
                        
                    }
                    
                    self.detectedCount = self.detectedCount + 1
                    if self.detectedCount == PhotoManager.sharedInstance.newPhotosList.count{
                        self.loadingNotification?.hide(animated: true)
                        self.detectedCount =  0
                        
                        self.findSimilarFaces()
                    }
                    
                    break
                case .failure(let error):
                    self.detectedCount = self.detectedCount + 1
                    self.loadingNotification?.hide(animated: true)
                    print("DetectFaces error - ", error)
                    self.present(Utils.alertWithTitle("Error", message: error.localizedDescription), animated: true, completion: {
                    })
                    break
                }
            })
        }
    }
    
    func findSimilarFaces(){
        
        self.loadingNotification?.label.text = "Finding similar faces in faces of photos"
        self.loadingNotification?.show(animated: true)
        
        var faceIds = [String]()
        for photo in PhotoManager.sharedInstance.newPhotosWithFaceList{
            for face in photo.faces {
                faceIds.append(face.faceId)
            }
        }
        
        FaceAPI.findSimilarFaces((self.userFace?.faceId)!, faces: faceIds) { (result: FaceAPIResult<AnyObject, Error>) in
            
            DispatchQueue.main.sync(execute: {
                
                switch result {
                case .success(let json):
                    self.loadingNotification?.hide(animated: true)
                    let similarFaces = json as! JSONArray
                    for item in similarFaces { // Detect only faces
                        
                        let similarFace = item as! JSONDictionary
                        let faceId = similarFace["faceId"] as! String   // Face Id
//                        let confidence = similarFace["confidence"] as! Double  // Confidence
                        for photo in PhotoManager.sharedInstance.newPhotosWithFaceList{
                            for face in photo.faces {
                                if faceId == face.faceId {
                                    let tempPhoto = MTImage()
                                    tempPhoto.faces.append(face)
                                    tempPhoto.image = photo.image
                                    tempPhoto.latitude = photo.latitude
                                    tempPhoto.longitude = photo.longitude
                                    tempPhoto.time = photo.time
                                    PhotoManager.sharedInstance.newPhotosWithUserFaceList.append(tempPhoto)
                                    PhotoManager.sharedInstance.storeObject(object: tempPhoto)
                
                                }
                                else{

                                }
                            }

                        }
                        
                    }
                    
                    //
                    self.performSegue(withIdentifier: "ChartViewController", sender: self)
                    break
                case .failure(let error):
                    self.loadingNotification?.hide(animated: true)
                    print("DetectFaces error - ", error)
                    self.present(Utils.alertWithTitle("Error", message: error.localizedDescription), animated: true, completion: {
                    })
                    break
                }
            })
        }
    }
    

    
    // MARK : Load ImageAssets when launching the app
    
    func requestPhotoAuthorization(_ resultHandler : @escaping (Bool) -> Void) -> Void {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.authorized {
            resultHandler(true)
        } else if status == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({ (_status: PHAuthorizationStatus) in
                if _status == PHAuthorizationStatus.authorized {
                    resultHandler(true)
                } else {
                    resultHandler(false)
                }
            })
        }
    }
    
    func loadAssets() -> Void {
        DispatchQueue.main.async {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            if self._assetsCollection != nil && self.assetsCollection.localizedTitle != nil {
                self.assetsFetchResults = PHAsset.fetchAssets(in: self._assetsCollection, options: options)
            } else {
                self.assetsFetchResults = PHAsset.fetchAssets(with: options)
            }
            if self.assetsFetchResults.count == 0 {
                
                self.present(Utils.alertWithTitle("Error", message: "No photo is detected, please take pictures to use this app."), animated: true, completion: nil)
            }
            else {
                
                PhotoManager.sharedInstance.addNewPhotos(fetchedResult: self.assetsFetchResults){ (result : Bool) in
                    
                    print("TOTAL NEW PHOTOS \(PhotoManager.sharedInstance.newPhotosList.count)")
                    if result == true{ // If new photos added
                        // Load saved user's photo
                        let filename = Utils.getTemporaryDirectory().appending("user.png")
                        if let imageUser = UIImage(contentsOfFile: filename) {
                            self.portraitView.image = imageUser
                            let resizedImage = imageUser.resize(toSize: CGSize(width:300,height:400), contentMode: UIImageContentMode.scaleAspectFit)
                            self.detectUserFace(image: resizedImage!) // detect user's  face
                        }
                        else{
                            
                            self.present(Utils.alertWithTitle("MoodTracker", message: "You're supposed to take a picture of your own, please choose correct one."), animated: true, completion: nil)
                        }
                    
                    }
                    else{ // No New photos added
                        
                        self.performSegue(withIdentifier: "ChartViewController", sender: self)
                    }
                }
                
            }
        }
    }
    
}

