//
//  DogWalkerViewController.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/18/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import UIKit
import Firebase

class DogWalkerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var WALKER_BTN_BACK: UIButton!
    @IBOutlet weak var WALKER_LBL_NAME: UILabel!
    @IBOutlet weak var WALKWE_LBL_MYDETAILS: UILabel!
    @IBOutlet weak var WALKER_LBL_NUMDOGS: UILabel!
    @IBOutlet weak var WALKER_LBL_MAXDOGS: UILabel!
    @IBOutlet weak var WALKER_LBL_INCOMES: UILabel!
    @IBOutlet weak var WALKER_TBL_REQUESTS: UITableView!
    @IBOutlet weak var WALKER_TBL_CLIENTS: UITableView!
    let CONFIRMED : String = "confirmed"
    let WAIT : String = "wait"
    let DECLINED : String = "declined"
    var numDogs : String?
    var incomes : String?
    var requests : [Walk] = []
    var clients : [Walk] = []
    var walker : DogWalker?
    var requestCellIndetifire = "requestCell"
    var clientCellIndetifire = "clientCell"
    var requestToFocud : Walk?
    var clientToFocus : Walk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRequests {
            self.updateData()
            self.setupTables()
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()}
        catch { print("already logged out")}
        if let nav = self.navigationController {
                   nav.popViewController(animated: true)
        } else {
                self.dismiss(animated: true, completion: nil)
               }
    }
    
    func loadRequests(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let RequestsFromDb = db.collection("Walks").whereField("dogWalkerId", isEqualTo: walker?.id! ?? "")
        RequestsFromDb.getDocuments(completion: { (result, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in result!.documents {
                    let status = document.get("status") as! String
                    if(status == self.WAIT){
                            self.requests.append(self.insertRequestToList(document: document))
                    }
                    else if (status == self.CONFIRMED){
                        self.clients.append(self.insertRequestToList(document: document))
                    }
                }
                self.WALKER_TBL_CLIENTS.reloadData()
                self.WALKER_TBL_REQUESTS.reloadData()
                completion()
            }
        })
    }
    
    func insertRequestToList(document : DocumentSnapshot) -> Walk{
        let clientName = document.get("clientName") as! String
        let dogWalkerName = document.get("dogWalkerName") as! String
        let clientId = document.get("clientId") as! String
        let dogWalkerId = document.get("dogWalkerId") as! String
        let price = document.get("price") as! String
        let status = document.get("status") as! String
        let dogAge = document.get("dogAge") as! String
        let dogKind = document.get("dogKind") as! String
        let walk = Walk(clientName: clientName, walkerName: dogWalkerName, clientId: clientId, walkerId: dogWalkerId, price: price, status: status, dogAge: dogAge, dogKind: dogKind)
        return walk
    }
    
    func updateData(){
        self.WALKER_LBL_NAME.text = "Hello " + (self.walker?.walkerName!.capitalized)!
        self.WALKWE_LBL_MYDETAILS.text = "My Details: " + (self.walker?.email!.capitalized)!
        self.WALKER_LBL_MAXDOGS.text = "MaxDogs" + ": " + (self.walker?.maxDogs!)!
        self.WALKER_LBL_NUMDOGS.text = "NumDogs: " + (String(self.clients.count))
        self.incomes = self.calcIncomes()
        self.WALKER_LBL_INCOMES.text = "Incomes: " + (self.incomes ?? "0") + " NIS"
    }
    
    func setupTables(){
        WALKER_TBL_REQUESTS.delegate = self
        WALKER_TBL_CLIENTS.delegate = self
        WALKER_TBL_CLIENTS.dataSource = self
        WALKER_TBL_REQUESTS.dataSource = self
        WALKER_TBL_REQUESTS.reloadData()
    }
    
    func calcIncomes() -> String{
        return String(self.clients.count * (Int((self.walker?.myPrice!)!) ?? 0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.WALKER_TBL_REQUESTS){
            return self.requests.count}
        if (tableView == self.WALKER_TBL_CLIENTS){
            return self.clients.count}
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.WALKER_TBL_REQUESTS){
        var cell : RequestCol? = self.WALKER_TBL_REQUESTS.dequeueReusableCell(withIdentifier: requestCellIndetifire) as? RequestCol
            
            cell?.REQUEST_LBL_NAME.text = "Client: " + (requests[indexPath.row].clientName!)
            cell?.REQUEST_LBL_AGE.text = "Age: " + requests[indexPath.row].dogAge!
            cell?.REQUEST_LBL_KIND.text = "Kind: " + requests[indexPath.row].dogKind!
            cell?.REQUEST_BTN_ACCEPT.tag = indexPath.row
            cell?.REQUEST_BTN_DECLINE.tag = indexPath.row
        
        if(cell == nil){
            cell = RequestCol(style: UITableViewCell.CellStyle.default, reuseIdentifier: requestCellIndetifire)
        }
            return cell!
        }
            
        else {
            var cell : ClientCol? = self.WALKER_TBL_CLIENTS.dequeueReusableCell(withIdentifier: clientCellIndetifire) as? ClientCol
              
            cell?.CLIENTCOL_LBL_NAME.text = "Client: " + clients[indexPath.row].clientName!
            cell?.CLIENTCOL_LBL_AGE.text = "Age: " + clients[indexPath.row].dogAge!
            cell?.CLIENTCOL_LBL_KIND.text = "Kind: " + clients[indexPath.row].dogKind!
            cell?.CLIENTCOL_BTN_CANCLE.tag = indexPath.row
              
              if(cell == nil){
                  cell = ClientCol(style: UITableViewCell.CellStyle.default, reuseIdentifier: clientCellIndetifire)
            }
            return cell!
        }
    }
    
    @IBAction func declineRequest(_ sender: UIButton) {
        if (self.requestToFocud != nil){
            self.requestToFocud?.status = DECLINED
            updateDataOnDB(walkToUpdate : self.requestToFocud!)
            for i in 0..<self.requests.count{
                if self.requests[i].clientId == self.requestToFocud!.clientId{
                    self.requests.remove(at: i)
                    self.reloadScreen(){
                    print("decline succede!")
                    }
                    return
                }
            }
        }
    }
    
    func updateDataOnDB(walkToUpdate : Walk) {
        let db = Firestore.firestore()
               let RequestsFromDb = db.collection("Walks").whereField("dogWalkerId", isEqualTo: walker?.id! ?? "")
               RequestsFromDb.getDocuments(completion: { (result, err) in
                   if let err = err {
                       print("Error getting documents: \(err)")
                   } else {
                       for document in result!.documents {
                           let clientId = document.get("clientId") as! String
                        if(clientId == walkToUpdate.clientId){
                            document.reference.updateData(walkToUpdate.encodable())
                           }
                       }
                   }
               })
    }
    
    func reloadScreen(completion: @escaping () -> Void) {
        updateData()
        self.WALKER_TBL_REQUESTS.reloadData()
        self.WALKER_TBL_CLIENTS.reloadData()
        completion()
    }
    
    @IBAction func acceptRequest(_ sender: UIButton) {
        if (self.requestToFocud != nil){
            if (Int(self.clients.count)<Int(self.walker!.maxDogs!)!){
                self.requestToFocud?.status = CONFIRMED
                updateDataOnDB(walkToUpdate: self.requestToFocud!)
                for i in 0..<self.requests.count{
                    if self.requests[i].clientId == self.requestToFocud!.clientId{
                        self.requests.remove(at: i)
                        self.clients.append(self.requestToFocud!)
                        self.reloadScreen(){
                        print("accept succede!")
                        }
                        return
                    }
                }
            }
            else{
                print("Too much clients!")
            }
        }
    }
    
    
    @IBAction func cancleClient(_ sender: UIButton) {
        if (self.clientToFocus != nil) {
            self.clientToFocus?.status = DECLINED
            updateDataOnDB(walkToUpdate : self.clientToFocus!)
            for i in 0..<self.clients.count{
                if self.clients[i].clientId == self.clientToFocus!.clientId {
                    self.clients.remove(at: i)
                    self.reloadScreen(){
                    print("cancelation succede!")
                }
                return
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.WALKER_TBL_REQUESTS){
            self.requestToFocud = self.requests[indexPath.row]
        }
        else {
            self.clientToFocus = self.clients[indexPath.row]
        }
    }
    


}
