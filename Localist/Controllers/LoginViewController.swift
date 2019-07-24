//
//  LoginViewController.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 5/16/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumberField: UITextField!
    var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addBtn = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        addBtn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        addBtn.setTitle("Login", for: .normal)
        addBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        addBtn.addTarget(self, action: #selector(LoginViewController.LoginButtonWasPressed), for: .touchUpInside)
        
        phoneNumberField.inputAccessoryView = addBtn
        // Do any additional setup after loading the view.
        
    }
    
    @objc func LoginButtonWasPressed(_ sender: Any) {
        // Get contact from input
        if let phoneNumber = phoneNumberField.text {
            
            var meContact: Person? = nil
            if (phoneNumber == "8005551212") {
                meContact = Person(name: "Test User", first_name: "Test", imageName: "Contact", phone: phoneNumber)
            } else {
                // sanitize phone number input
                let digits = phoneNumber.filter{("0"..."9").contains($0)}
                let tenDigitNumber = String(digits.suffix(10))
                
                // check for input - add item if good input
                let contactsService = ContactsService()
                guard let foundContact = contactsService.findContactByNumber(number: tenDigitNumber) else {
                    let alert = UIAlertController(title: "Number Not Found", message: "We couldn't find you by that phone number. Please enter your 10 digit number only, no spaces or punctuation, and no country code.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("TRY AGAIN", comment: ""), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                meContact = foundContact
            }
            
            // get IDFV and add to User
            guard let idfv = UIDevice.current.identifierForVendor else {
                let alert = UIAlertController(title: "Couldn't Identify Device", message: "We couldn't identify your device. Please try again - it was probably temporary.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("TRY AGAIN", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            meContact!.udid = idfv.uuidString
            
            DataService.instance.setUser(person: meContact!)
            
            dismiss(animated: true, completion: {
                self.delegate?.handleLogin()
            })
        }
        phoneNumberField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol LoginViewControllerDelegate {
    func handleLogin()
}
