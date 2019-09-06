//
//  RequestManeger.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/3/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

class RequestManeger: UIViewController {
    
    func getInfoLigan(nameLigan: String, completion: @escaping(String, String?)->Void) {
        if let fileUrl = URL(string: "http://files.rcsb.org/ligands/view/\(nameLigan)_ideal.sdf") {
            do {
                let contents = try String(contentsOf: fileUrl)
                // This check for an empty file. If if true, try take from another file
                if contents.isEmpty {
                    if let fileUrlModel = URL(string: "http://files.rcsb.org/ligands/view/\(nameLigan)_model.sdf") {
                        do {
                            let contents1 = try String(contentsOf: fileUrlModel)
                            if contents1.isEmpty
                            {
                                completion("", "Bad source. It is empty")
                            } else {
                                completion(contents1, nil)
                            }
                        }
                    }
                } else {
                    completion(contents, nil)
                }
            } catch {
                // Contents could not be loaded
                completion("", "Contents could not be loaded")
            }
        } else {
            // Bad url!
            completion("", "Bad url")
        }
    }
    
    func getListLigans(completion: @escaping([String], String?)->Void) {
        if let filepath = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                var allLigans = contents.components(separatedBy: "\n")
                allLigans.removeLast()
                completion(allLigans, nil)
            } catch {
                // contents could not be loaded
                completion([], "Contents could not be loaded")
            }
        } else {
            // example.txt not found!
            completion([], "ligands not found")
        }
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
