//
//  VerifyPhoneVC.swift
//  Cashably
//
//  Created by apollo on 6/17/22.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import FirebaseAuth

class VerifyPhoneVC: UIViewController, NVActivityIndicatorViewable {
    
    var window: UIWindow?
    
    public var type: String!
    public var phone: String!
 
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnTryAgain: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lbPhone: UILabel!
    
    @IBOutlet weak var tfCode1: UITextField!
    @IBOutlet weak var tfCode2: UITextField!
    @IBOutlet weak var tfCode3: UITextField!
    @IBOutlet weak var tfCode4: UITextField!
    @IBOutlet weak var tfCode5: UITextField!
    @IBOutlet weak var tfCode6: UITextField!
    
    private var authError: NSError!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tfCode1.delegate = self
        tfCode2.delegate = self
        tfCode3.delegate = self
        tfCode4.delegate = self
        tfCode5.delegate = self
        tfCode6.delegate = self
        tfCode1.keyboardType = .numberPad
        tfCode1.textContentType = .oneTimeCode
        self.lbPhone.text = phone
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.isNavigationBarHidden = true
        
        
   }

    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       self.navigationController?.isNavigationBarHidden = false
       
   }
    
    func moveToMain() {
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        self.window?.rootViewController = mainVC
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
    func moveToSignupWithEmail() {
        let signupWithEmailVC = storyboard?.instantiateViewController(withIdentifier: "SignupWithEmailVC") as! SignupWithEmailVC
        navigationController?.pushViewController(signupWithEmailVC, animated: true)
    }
    
    func moveToLogin() {
        self.stopAnimating()
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        navigationController?.pushViewController(loginVC, animated: true)
    }

    func moveToCompleteProfile() {
        self.stopAnimating()
        let profileCompleteVC = storyboard?.instantiateViewController(withIdentifier: "ProfileCompleteVC") as! ProfileCompleteVC
        navigationController?.pushViewController(profileCompleteVC, animated: true)
    }
    
    @IBAction func actionConfirm(_ sender: UIButton) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            return
        }
        
        let code = "\(tfCode1.text!)\(tfCode2.text!)\(tfCode3.text!)\(tfCode4.text!)\(tfCode5.text!)\(tfCode6.text!)"
        print(code)
        self.startAnimating()
        
        let credential = PhoneAuthProvider.provider().credential(
              withVerificationID: verificationID,
              verificationCode: code
        )
        
        if self.type == "signin" {
            Auth.auth().signIn(with: credential) { authResult, error in
                self.stopAnimating()
                if let error = error {
                    self.authError = error as NSError
                    let alert = Alert.showBasicAlert(message: error.localizedDescription)
                    self.presentVC(alert)
                    return
                }
               
                // User is signed in
                // ...
                if let user = Auth.auth().currentUser {
                    if user.displayName == nil || user.email == nil {
                        self.moveToCompleteProfile()
                    } else {
                        self.moveToMain()
                    }
                } else {
                    self.moveToLogin()
                }
            }
        } else {
            Auth.auth().checkActionCode(code) { codeInfo, error in
                self.stopAnimating()
                self.moveToSignupWithEmail()
            }
            
        }
        
        
    }
    
    
    @IBAction func actionTryAgain(_ sender: UIButton) {
        if self.authError.code == AuthErrorCode.secondFactorRequired.rawValue {
        // The user is a multi-factor user. Second factor challenge is required.
            let resolver = self.authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
            var displayNameString = ""
            for tmpFactorInfo in resolver.hints {
                  displayNameString += tmpFactorInfo.displayName ?? ""
                  displayNameString += " "
            }
            
            var selectedHint: PhoneMultiFactorInfo?
            
            for tmpFactorInfo in resolver.hints {
                selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
            }
            
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                    if error != nil {
                          print(
                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
                          )
                        let alert = Alert.showBasicAlert(message: error!.localizedDescription)
                        self.presentVC(alert)
                    } else {
                        print(
                          "Sent code"
                        )
                        self.showToast(message: "Sent code again")
                    }
                }
                
        }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension VerifyPhoneVC: UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // make sure the result is under 16 characters
        return updatedText.count <= 1
    }
}