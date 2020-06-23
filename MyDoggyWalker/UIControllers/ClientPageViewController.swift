//
//  ClientPageViewController.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/18/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import Firebase

class ClientPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var CLIENT_LBL_NAME: UILabel!
    @IBOutlet weak var CLIENT_LBL_KIND: UILabel!
    @IBOutlet weak var CLIENT_LBL_AGE: UILabel!
    @IBOutlet weak var CLIENT_LBL_USERNAME: UILabel!
    @IBOutlet weak var CLIENT_BTN_BACK: UIButton!
    @IBOutlet weak var CLIENT_TBL_AVAILABLE: UITableView!
    @IBOutlet weak var CLIENT_MAP_LOCATION: MKMapView!
    @IBOutlet weak var CLIENT_TBL_STATUS: UITableView!
    let CONFIRMED : String = "confirmed"
    let WAIT : String = "wait"
    let DECLINED : String = "declined"
    let availableColIdentifire = "availablecol"
    let statusColIdentifire = "statuscol"
    let walkerType = "dogWalker"
    var myCamera: MKMapCamera!
    var numOfStatus : Int = 0
    var client : Client?
    var walkerForInvite : DogWalker?
    var walkersList : [DogWalker] = []
    var myWalksList : [Walk] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWalkers {
            // TODO load walks
            // TODO update status table
            // TODO automatic listener for status
            print(self.walkersList)
            self.updateWalkes {
                self.CLIENT_MAP_LOCATION.showsUserLocation = true
                self.CLIENT_MAP_LOCATION.layer.cornerRadius = 50.0
                self.updateData()
                self.addLocationsToMap()
                self.setupTables()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func loadWalkers(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let walkersFromDb = db.collection("Users").whereField("type", isEqualTo: walkerType)
        walkersFromDb.getDocuments(completion: { (result, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in result!.documents {
                    self.walkersList.append(self.insertOnWalkerToList(document: document))
                }
                completion()
            }
        })
    }
    
    func insertOnWalkerToList(document : DocumentSnapshot) -> DogWalker{
        let walkerName = document.get("walkerName") as! String
        let myPrice = document.get("myPrice") as! String
        let maxDogs = document.get("maxDogs") as! String
        let email = document.get("email") as! String
        let id = document.get("id") as! String
        let location = Loc(lat : document.get("myLocLat") as! Double, lon : document.get("myLocLon") as! Double)
        let password = document.get("password") as! String
        let walker = DogWalker(email: email, name: walkerName, password: password, myPrice: myPrice, maxDogs: maxDogs, location: location, myId: id)
        return walker
    }
    
    func updateData() {
        let userName = self.CLIENT_LBL_USERNAME.text!
        let dogNameLBL = self.CLIENT_LBL_NAME.text!
        let dogAgeLBL = self.CLIENT_LBL_AGE.text!
        let dogKindLBL = self.CLIENT_LBL_KIND.text!
        self.CLIENT_LBL_USERNAME.text = userName + " " + ((self.client?.name)!.capitalized)
        self.CLIENT_LBL_NAME.text = dogNameLBL + ": " + (self.client?.dogName!.capitalized)!
        self.CLIENT_LBL_AGE.text = dogAgeLBL + ": " + (self.client?.dogAge)!
        self.CLIENT_LBL_KIND.text = dogKindLBL + ": " + (self.client?.dogKind!.capitalized)!
    }
    
    func setupTables(){
        CLIENT_TBL_AVAILABLE.delegate = self
        CLIENT_TBL_STATUS.delegate = self
        CLIENT_TBL_STATUS.dataSource = self
        CLIENT_TBL_AVAILABLE.dataSource = self
        CLIENT_TBL_AVAILABLE.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.CLIENT_TBL_AVAILABLE){
            return self.walkersList.count}
        if (tableView == self.CLIENT_TBL_STATUS){
            return self.myWalksList.count}
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.CLIENT_TBL_AVAILABLE){
        var cell : AvailableDogWalkerCol? = self.CLIENT_TBL_AVAILABLE.dequeueReusableCell(withIdentifier: availableColIdentifire) as? AvailableDogWalkerCol
            
            cell?.AVAILABLE_LBL_NAME?.text = "Name: " + (walkersList[indexPath.row].walkerName!)
            cell?.AVAILABLE_LBL_PRICE?.text = "Price: " + walkersList[indexPath.row].myPrice!
            for walk in myWalksList{
                if walk.dogWalkerId == walkersList[indexPath.row].id{
                    cell?.AVAILABLE_BTN_INVITE.isEnabled = false
                }
            }
        
        if(cell == nil){
            cell = AvailableDogWalkerCol(style: UITableViewCell.CellStyle.default, reuseIdentifier: availableColIdentifire)
        }
            return cell!
        }
            
        else {
            var cell : DogWalkerStatusCol? = self.CLIENT_TBL_STATUS.dequeueReusableCell(withIdentifier: statusColIdentifire) as? DogWalkerStatusCol
              
            cell?.STATUS_LBL_NAME.text = "Name: " + myWalksList[indexPath.row].dogWalkerName!
            cell?.STATUS_LBL_PRICE.text = "Price: " + myWalksList[indexPath.row].price!
            cell?.STATUS_LBL_STATUS.text = "Status: " + myWalksList[indexPath.row].status!
              
              if(cell == nil){
                  cell = DogWalkerStatusCol(style: UITableViewCell.CellStyle.default, reuseIdentifier: statusColIdentifire)
            }
            return cell!
        }
    }
    
    
    @IBAction func OnBackPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()}
        catch { print("already logged out")}
        if let nav = self.navigationController {
                   nav.popViewController(animated: true)
        } else {
                self.dismiss(animated: true, completion: nil)
               }
    }
    
    @IBAction func inviteDogWalker(_ sender: UIButton) {
        print("invite")
            if (self.walkerForInvite != nil) {
            let walk = Walk(client: client!, walker: walkerForInvite!, price: walkerForInvite!.myPrice!)
                for pervious in self.myWalksList{
                    if (pervious.dogWalkerId == walk.dogWalkerId){
                        return
                    }
                }
            let db = Firestore.firestore()
            db.collection("Walks").addDocument(data: walk.encodable())
            sender.isEnabled = false
            updateWalkes(){
                print("walks Updated!")
            }
        }
    }
    
    func updateWalkes(completion: @escaping () -> Void){
        self.myWalksList.removeAll()
        let db = Firestore.firestore()
        let walkersFromDb = db.collection("Walks").whereField("clientId", isEqualTo: client!.id!)
        walkersFromDb.getDocuments(completion: { (result, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in result!.documents {
                        self.myWalksList.append(self.insertWalk(document: document))
                    }
                self.CLIENT_TBL_STATUS.reloadData()
                completion()
            }
        })
    }
    
    func insertWalk(document : DocumentSnapshot) -> Walk{
        let dogWalkerId = document.get("dogWalkerId") as! String
        let clientName = document.get("clientName") as! String
        let dogWalkerName = document.get("dogWalkerName") as! String
        let clientId = document.get("clientId") as! String
        let price = document.get("price") as! String
        let status = document.get("status") as! String
        let dogAge = document.get("dogAge") as! String
        let dogKind = document.get("dogKind") as! String
        let walk = Walk(clientName: clientName, walkerName: dogWalkerName, clientId: clientId, walkerId: dogWalkerId, price: price, status: status, dogAge: dogAge, dogKind: dogKind)
        return walk
    }
    

    func addLocationsToMap(){
            for walker in walkersList{
            let point = MKPointAnnotation()
            let pointlatitude = Double(walker.myLoc!.lat)
            let pointlongitude = Double(walker.myLoc!.lon)
            point.title = walker.walkerName
            
            point.coordinate = CLLocationCoordinate2DMake(pointlatitude ,pointlongitude)
            CLIENT_MAP_LOCATION.addAnnotation(point)
        }
    }
    
    func showLocationOnMap(index : Int){
        myCamera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: walkersList[index].myLoc!.lat, longitude: walkersList[index].myLoc!.lon), fromDistance: 300, pitch: 90.0, heading: 180.0)
        self.CLIENT_MAP_LOCATION.setCamera(myCamera, animated: true)
    
    }
    
    func storeWalkerForInvite(index : Int){
        self.walkerForInvite = self.walkersList[index]
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLocationOnMap(index: indexPath.row)
        storeWalkerForInvite(index: indexPath.row)
    }

}
