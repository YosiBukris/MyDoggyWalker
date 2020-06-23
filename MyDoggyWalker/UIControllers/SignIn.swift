//
//  ViewController.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/12/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignIn: UIViewController {
    
    @IBOutlet weak var MAIN_TXT_MAIL: UITextField!
    @IBOutlet weak var MAIN_TXT_PASSWORD: UITextField!
    @IBOutlet weak var MAIN_BTN_SIGNIN: UIButton!
    @IBOutlet weak var MAIN_BTN_SIGNUP: UIButton!
    let clientType = "client"
    let walkerType = "dogWalker"
    var client : Client?
    var walker : DogWalker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToSignUp(_ sender: Any) {
        performSegue(withIdentifier: "SignUpSegue", sender: self)
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        let email = self.MAIN_TXT_MAIL.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.MAIN_TXT_PASSWORD.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if (error != nil){
                self.MAIN_TXT_MAIL.text = error!.localizedDescription
                self.MAIN_TXT_MAIL.textColor = UIColor.red
            }
            else {
                self.getDataToSignIn(email : email)
            }
        }
    }
    
    func getDataToSignIn(email : String){
        let db = Firestore.firestore()
        let user = db.collection("Users").document(email)
        user.getDocument { (result, error) in
            if (error != nil){
                self.MAIN_TXT_MAIL.text = error!.localizedDescription
                self.MAIN_TXT_MAIL.textColor = UIColor.red
            }
            else {
                let type = result?.get("type") as! String
                    if (type == self.clientType){
                       print("Client Login Succes")
                        self.initClient(email : email, result : result!)
                        self.performSegue(withIdentifier: "SignInClientSegue", sender: self)
                    }
                    else if (type == self.walkerType){
                        print("Walker Login Succes")
                        self.initWalker(email : email, result : result!)
                        self.performSegue(withIdentifier: "SignInWalkerSegue", sender: self)
                    }
            }
        }
    }
    
    func initClient(email : String, result : DocumentSnapshot){
        let name = result.get("name") as! String
        let dogAge = result.get("dogAge") as! String
        let dogKind = result.get("dogKind") as! String
        let dogName = result.get("dogName") as! String
        let email = result.get("email") as! String
        let id = result.get("id") as! String
        let location = Loc(lat : result.get("myLocLat") as! Double, lon : result.get("myLocLon") as! Double)
        let password = result.get("password") as! String
        self.client = Client(email: email, name: name, pass: password, location: location, dogName: dogName, dogKind: dogKind, dogAge: dogAge, myId: id)
    }
    
    func initWalker(email : String, result : DocumentSnapshot){
        let walkerName = result.get("walkerName") as! String
        let myPrice = result.get("myPrice") as! String
        let maxDogs = result.get("maxDogs") as! String
        let email = result.get("email") as! String
        let id = result.get("id") as! String
        let location = Loc(lat : result.get("myLocLat") as! Double, lon : result.get("myLocLon") as! Double)
        let password = result.get("password") as! String
        self.walker = DogWalker(email: email, name: walkerName, password: password, myPrice: myPrice, maxDogs: maxDogs, location: location, myId: id)
    }
    

    @IBAction func clearField(_ sender: UITextField) {
        sender.text = ""
        sender.textColor = UIColor.black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "SignUpSegue"){
            _ = segue.destination as! SignUp
        }
        if(segue.identifier == "SignInClientSegue"){
            let vc = segue.destination as! ClientPageViewController
            vc.client = self.client
        }
        if(segue.identifier == "SignInWalkerSegue"){
            let vc = segue.destination as! DogWalkerViewController
            vc.walker = self.walker
        }
        
    }
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

