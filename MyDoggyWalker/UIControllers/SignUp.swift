//
//  SignUp.swift
//  MyDoggyWalker
//
//  Created by user166548 on 6/13/20.
//  Copyright © 2020 user166548. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import CoreLocation

class SignUp: UIViewController {
    @IBOutlet weak var SIGNUP_TXT_EMAIL: UITextField!
    @IBOutlet weak var SIGNUP_TXT_PASS: UITextField!
    @IBOutlet weak var SIGNUP_TYPE: UISegmentedControl!
    @IBOutlet weak var SIGNUP_BTN_SIGN: UIButton!
    @IBOutlet weak var SIGNUP_BTN_BACK: UIButton!
    @IBOutlet weak var SIGNUP_TXT_DOGNAMEORPRICE: UITextField!
    @IBOutlet weak var SIGNUP_TXT_DOGAGEORMAX: UITextField!
    @IBOutlet weak var SIGNUP_TXT_DOGKIND: UITextField!
    @IBOutlet weak var SIGNUP_TXT_NAME: UITextField!
    @IBOutlet weak var SIGNUP_LBL_DETAILSMODE: UILabel!
    let EmptyFieldsEror = "please fill in all fields."
    let wrongPassword = "password isn't valied! (at least 8 characters, contains special character and a number)"
    let wrongEmail = "email isn't valied!"
    var locationManager: CLLocationManager!
    var myLocation : Loc!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        if let nav = self.navigationController {
                   nav.popViewController(animated: true)
        } else {
                self.dismiss(animated: true, completion: nil)
               }
    }
    
    func validateFields() -> String?{
        if (SIGNUP_TXT_EMAIL.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            SIGNUP_TXT_PASS.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            SIGNUP_TXT_DOGAGEORMAX.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            SIGNUP_TXT_DOGNAMEORPRICE.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            SIGNUP_TXT_NAME.text?.trimmingCharacters(in: .whitespacesAndNewlines ) == ""){
            SIGNUP_TXT_NAME.text = EmptyFieldsEror
            SIGNUP_TXT_NAME.textColor = UIColor.red
            return EmptyFieldsEror
        }
        
//        let cleanedPassword = SIGNUP_TXT_PASS.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        if(!isPasswordValid(cleanedPassword)){
//            SIGNUP_TXT_PASS.text = wrongPassword
//            return wrongPassword}
        
//        if(!isValidEmail(SIGNUP_TXT_EMAIL.text!)){
//            SIGNUP_TXT_EMAIL.text = wrongEmail
//            return wrongEmail
//        }
        return nil
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            self.SIGNUP_LBL_DETAILSMODE.text = "Dog Details"
            self.SIGNUP_TXT_DOGNAMEORPRICE.placeholder = "Dog Name"
            self.SIGNUP_TXT_DOGAGEORMAX.placeholder = "Dog Age"
            self.SIGNUP_TXT_DOGKIND.alpha = 1
        }
        else {
            self.SIGNUP_LBL_DETAILSMODE.text = "More Details"
            self.SIGNUP_TXT_DOGNAMEORPRICE.placeholder = "Price"
            self.SIGNUP_TXT_DOGAGEORMAX.placeholder = "Max Dogs"
            self.SIGNUP_TXT_DOGKIND.alpha = 0
        }
    }
    
    
    
//    func isPasswordValid(_ password : String) -> Bool{
//        let predicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z](?=.*[0-9].{>8}$")
//        return predicate.evaluate(with: password)
//    }
    
//    func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }

    @IBAction func clearField(_ sender: UITextField) {
        sender.text = ""
        sender.textColor = UIColor.black
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        //validate the fields
        let error = validateFields()
        if (error != nil){
            return}
        else{
            let userName = SIGNUP_TXT_NAME.text!
            let passwrod = SIGNUP_TXT_PASS.text!
            let email = SIGNUP_TXT_EMAIL.text!
            let userType = SIGNUP_TYPE.selectedSegmentIndex
            let dogNameOrPrice = SIGNUP_TXT_DOGNAMEORPRICE.text!
            let dogAgeOrMax = SIGNUP_TXT_DOGAGEORMAX.text!
            let dogKind = SIGNUP_TXT_DOGKIND.text!
            Auth.auth().createUser(withEmail: self.SIGNUP_TXT_EMAIL.text!, password: self.SIGNUP_TXT_PASS.text!) { (result, err) in
                if err != nil{
                    self.SIGNUP_TXT_NAME.text = err?.localizedDescription
                    self.SIGNUP_TXT_NAME.textColor = UIColor.red
                }
                if (result != nil){
                    let db = Firestore.firestore()
                    if (userType == 0){
                        let client = Client(email: email, name: userName, pass: passwrod, location: self.myLocation!, dogName: dogNameOrPrice, dogKind:dogKind, dogAge: dogAgeOrMax, myId: result!.user.uid)
                        db.collection("Users").document(email).setData(client.encodable())
                        self.goToSignIn()
                    }
                    else{
                        let walker = DogWalker(email : email ,name : userName, password : passwrod, myPrice : dogNameOrPrice, maxDogs : dogAgeOrMax, location : self.myLocation, myId : result!.user.uid)
                        db.collection("Users").document(email).setData(walker.encodable()) { (error) in
                            if error != nil {
                                self.SIGNUP_TXT_NAME.text = "Error Saving Data!"
                                self.SIGNUP_TXT_NAME.textColor = UIColor.red
                            }
                        }
                        self.goToSignIn()
                    }
                }
            }
        }
        
        //Transision to the home screen
    
    }
    
    func goToSignIn(){
        self.performSegue(withIdentifier: "goToSignInAfterSignUp", sender: nil)
    }

}

extension SignUp: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")

        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            myLocation = Loc(lat: lat, lon: lon)
            print("got Location: \(lat) \(lon)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        myLocation = Loc(lat: 0, lon: 0)
    }
}

