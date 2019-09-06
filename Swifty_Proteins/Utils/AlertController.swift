//
//  AlertController.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/6/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

class AlertController: UIViewController {
    
    func showMessage(message : String, view: UIView) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 75,
                                               y: view.frame.size.height-50,
                                               width: 150, height: 35))
        
        toastLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 20.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {
            (isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func alertController(_ message: String) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertController
    }
}
