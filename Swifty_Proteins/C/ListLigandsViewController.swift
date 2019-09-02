//
//  ListLigandsViewController.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/2/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

class ListLigandsViewController: UIViewController, UISearchBarDelegate {

    var listLigans: [String] = []
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func buttomSearch(_ sender: UIBarButtonItem) {
         //Show Search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    @objc func appMovedToBackground() {
        // App moved to Background!
        print("App moved to Background!")
        performSegue(withIdentifier: "backFromListToLogin", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getListLigans()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check and do actions when apps move to Background!
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
}

extension ListLigandsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listLigans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandsCell", for: indexPath) as! ListLigandsTableViewCell
        cell.numberRow.text = "\(indexPath.row + 1)."
        cell.nemeLigand.text = listLigans[indexPath.row]
        return cell
    }
}

extension ListLigandsViewController {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Hide search bar and show row with search word
        searchBar.resignFirstResponder()
        guard let searchLigand = searchBar.text else { return }
        if let index = self.listLigans.firstIndex(of: String(searchLigand).uppercased()) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
            showAlertController("Didn't find this ligand")
        }
    }
    
    func getListLigans() {
        if let filepath = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                self.listLigans = contents.components(separatedBy: "\n")
                self.listLigans.removeLast()
            } catch {
                // contents could not be loaded
                showAlertController("Contents could not be loaded")
            }
        } else {
            // example.txt not found!
            showAlertController("ligands not found!")
        }
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
