//
//  MTImgMetaInfo.swift
//  MoodTracker
//
//  Created by axiom88 05/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//


import Foundation
import UIKit
import RealmSwift


public class MTImage: Object {

    // MARK: Properties

    dynamic var image = Data()
    dynamic var latitude : Double = 0.0
    dynamic var longitude : Double = 0.0
    dynamic var time = Date()
    let faces = List<Face>()
    
//    override public static func primaryKey() -> String? {
//        return "id"
//    }
 

}

