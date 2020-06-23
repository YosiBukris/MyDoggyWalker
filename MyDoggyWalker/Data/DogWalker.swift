//
//  DogWalker.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/20/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import Foundation

class DogWalker : Codable{
    var id : String?
    var walkerName : String?
    var password : String?
    var email : String?
    var myPrice : String?
    var maxDogs : String?
    var myLoc : Loc?
    let type : String = "dogWalker"
    
    init(email : String ,name : String, password : String, myPrice : String, maxDogs : String, location : Loc, myId : String){
        self.myLoc = location
        self.email = email
        self.myPrice = myPrice
        self.password = password
        self.maxDogs = maxDogs
        self.walkerName = name
        self.id = myId
    }

    
    func encodable() -> Dictionary<String, Any>{
        return
            ["id" : self.id ?? "", "walkerName" : self.walkerName ?? "","email" : self.email ?? "", "password" : self.password ?? "", "myLocLat" : self.myLoc?.lat ?? 0.0, "myLocLon" : self.myLoc?.lon ?? 0.0, "myPrice" : self.myPrice ?? "", "maxDogs" : self.maxDogs ?? "", "type" : self.type]
    }
    
    
}
