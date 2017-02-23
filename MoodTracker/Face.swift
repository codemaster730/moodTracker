//
//  Face.swift
//  MoodTracker
//
//  Created by axiom88 06/10/2016.
//  Copyright © 2016 Axiom. All rights reserved.
//

import Foundation
import RealmSwift

public class Face : Object {
    
    dynamic var faceId: String = ""
    dynamic var  height: Int = 0
    dynamic var  width: Int = 0
    
    dynamic var  top: Int = 0
    dynamic var  left: Int = 0
    dynamic var  age: Double = 0.0
    dynamic var  gender : String = ""
    dynamic var  smile : Double = 0.0
}
