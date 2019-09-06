//
//  LoginViewController.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/2/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    let context = LAContext()
    var backFromAnotherView = false
    private let alertController = AlertController()
    @IBOutlet weak var buttomTouchID: UIButton!
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        print(segue.identifier ?? "")
        self.backFromAnotherView = true
    }
    
    @IBAction func authWithTouchID(_ sender: UIButton) {
        enterWithTouch()
    }
    
    @objc func appMovedToForeground() {
        // App moved to ForeGround!
        print("App moved to ForeGround!")
        enterWithTouch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.backFromAnotherView == false {
            enterWithTouch()
            self.backFromAnotherView = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        touchIdIsAvailabe()
        // Check and do actions when apps move from Background!
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
    }
}

extension LoginViewController {
    
    func touchIdIsAvailabe() {
        // Check for what biometry type apps has
        if context.biometryType == .faceID {
            self.buttomTouchID.setImage(#imageLiteral(resourceName: "face"), for: .normal)
        } else if context.biometryType == .touchID {
            self.buttomTouchID.setImage(#imageLiteral(resourceName: "touch"), for: .normal)
        } else {
            self.buttomTouchID.setImage(#imageLiteral(resourceName: "password"), for: .normal)
        }
    }
    
    func enterWithTouch() {
        // Get the authentication context from the Local Authentication framework.
        let context = LAContext()
        var error: NSError?
        //Check if Touch ID is available.The canEvaluatePolicy method checks if Touch ID is available on the device.
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // The policy is evaluated where the third parameter is a completion handler block.
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { [weak self] (success, error) in
                guard let self = self else { return }
                // An Alert message is shown wether the Touch ID authentication succeeded or not
                if success {
                    DispatchQueue.main.async { [unowned self] in
                        self.backFromAnotherView = false
                        self.performSegue(withIdentifier: "fromLoginToListLigands", sender: .none)
                        print("Touch ID Authentication Succeeded")
                    }
                } else {
                    print("TouchID or FaceID Authentication Failed")
                    DispatchQueue.main.async { [unowned self] in
                        self.present(self.alertController.alertController("Authentication Failed"), animated: true, completion: nil)
                    }
                }
            })
        } else {
            //If Touch ID is not available an Alert message is shown.
            print("TouchID or FaceID not available")
            self.present(self.alertController.alertController("Authentication not available"), animated: true, completion: nil)
        }
    }
}
