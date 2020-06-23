//
//  Walk.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/21/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import Foundation

class Walk : Codable{
    let CONFIRMED : String = "confirmed"
    let WAIT : String = "wait"
    let DECLINED : String = "declined"
    var clientName : String?
    var dogWalkerName : String?
    var clientId : String?
    var dogWalkerId : String?
    var dogKind : String?
    var dogAge : String?
    var price : String?
    var status : String?
    
    init (client: Client, walker : DogWalker, price : String){
        self.clientName = client.name
        self.clientId = client.id
        self.dogWalkerName = walker.walkerName
        self.dogWalkerId = walker.id
        self.price = price
        self.status = WAIT
        self.dogAge = client.dogAge
        self.dogKind = client.dogKind
    }
    
    init (clientName: String, walkerName : String, clientId : String , walkerId : String, price : String, status : String, dogAge : String, dogKind : String){
        self.clientName = clientName
        self.clientId = clientId
        self.dogWalkerName = walkerName
        self.dogWalkerId = walkerId
        self.price = price
        self.status = status
        self.dogKind = dogKind
        self.dogAge = dogAge
    }
    
    func encodable() -> Dictionary<String, Any>{
        return
            ["clientName" : clientName!, "dogWalkerName" : dogWalkerName!, "clientId" : clientId!, "dogWalkerId" : dogWalkerId!, "price" : price!, "status" : status!
                , "dogAge" : dogAge!, "dogKind" : dogKind!]
    }
}

