//
//  Client.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/20/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import Foundation

class Client : Codable{
    var id : String?
    var name : String?
    var email : String?
    var password : String?
    var myLoc : Loc?
    var dogName : String?
    var dogKind : String?
    var dogAge : String?
    let type : String = "client"
    
    init( email : String, name : String, pass : String, location : Loc, dogName : String, dogKind: String, dogAge : String, myId : String){
        self.name = name
        self.password = pass
        self.myLoc = location
        self.dogName = dogName
        self.dogKind = dogKind
        self.dogAge = dogAge
        self.id = myId
        self.email = email
    }
    
    func encodable() -> Dictionary<String, Any>{
        return
            ["id" : self.id ?? "", "name" : self.name ?? "","email" : self.email ?? "", "password" : self.password ?? "", "myLocLat" : self.myLoc?.lat ?? 0.0, "myLocLon" : self.myLoc?.lon ?? 0.0, "dogName" : self.dogName ?? "", "dogKind" : self.dogKind ?? "", "dogAge" : self.dogAge ?? "", "type" : self.type]
    }
}
