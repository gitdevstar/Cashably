//
//  SignupWithEmailVC.swift
//  Cashably
//
//  Created by apollo on 6/17/22.
//

import Foundation
import UIKit
import FirebaseAuth
import NVActivityIndicatorView

class SignupWithEmailVC: UIViewController, NVActivityIndicatorViewable {
    
    var window: UIWindow?
    
    @IBOutlet weak var btnSIgnup: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.isNavigationBarHidden = true
   }

    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       self.navigationController?.isNavigationBarHidden = false
   }
    
    func moveToProfile() {
        let profileEditVC = storyboard?.instantiateViewController(withIdentifier: "ProfileEditVC") as! ProfileEditVC
        navigationController?.pushViewController(profileEditVC, animated: true)
    }
    
    @IBAction func actionSignup(_ sender: UIButton) {
        self.startAnimating()
        Auth.auth().createUser(withEmail: tfEmail.text!, password: tfPassword.text!) { [weak self] authResult, error in
            self?.stopAnimating()
            guard let strongSelf = self else { return }
          // ...
            self?.moveToProfile()
        }
    }
    
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}