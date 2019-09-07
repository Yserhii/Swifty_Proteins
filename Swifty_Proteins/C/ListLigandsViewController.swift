//
//  ListLigandsViewController.swift
//  Swifty_Proteins
//
//  Created by Yolankyi SERHII on 9/2/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

class ListLigandsViewController: UIViewController, UISearchBarDelegate {
    
    private var listLigans: [String] = []
    private var searchListLigans: [String] = []
    private var treeInfiLigans: [String : [[String : String]]] = [:]
    private var requestManeger = RequestManeger()
    private let alertController = AlertController()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //Up top tableView
    @IBAction func upTopButtom(_ sender: UIBarButtonItem) {
        self.tableView.scrollToTop(animated: true)
    }
    
    @objc func handleRefreshControl() {
        searchListLigans = listLigans
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func configureRefreshControl () {
        //Pull to refresh and request by filters
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = .red
        self.tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Hide search bar and show row with search word
        dismiss(animated: true, completion: nil)
    }
    //Search ligans
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchListLigans = searchText.isEmpty ? listLigans : listLigans.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    @IBAction func buttomSearch(_ sender: UIBarButtonItem) {
         //Show Search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
//        searchController.searchBar.resignFirstResponder()
        present(searchController, animated: true, completion: nil)
    }
    
    @objc func appMovedToBackground() {
        // App moved to Background!
        print("App moved to Background!")
        performSegue(withIdentifier: "backFromListToLogin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowLagands") {
            let ligandViewController = segue.destination as! LigandViewController
            ligandViewController.infoLigan = self.treeInfiLigans
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getListLigans()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
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
        return self.searchListLigans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandsCell", for: indexPath) as! ListLigandsTableViewCell
        cell.numberRow.text = "\(indexPath.row + 1)."
        cell.nemeLigand.text = self.searchListLigans[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getInfoLigan(nameLigan: searchListLigans[indexPath.row])
    }
}

extension ListLigandsViewController {
    
    func parsinginfoLigan(allInfro: String) {
        var numNode: Int = 0
        var numLink: Int = 0
        //Break into arrays by "\n" than in it array break by space
        let ligans = allInfro.split(separator: "\n").map{$0.split(separator: " ")}
        //Add in dictionary name ligans, num nodes, num links
        self.treeInfiLigans.updateValue([["nodename" : String(ligans[0][0])]], forKey: "name")
        //This is a check for connected together in one string number Nodes with number links.
        let count = String(ligans[2][0]).count
        if count > 3 {
            numNode = Int(String(ligans[2][0].dropLast(count / 2))) ?? 0
            numLink = Int(String(ligans[2][0].dropFirst(count / 2))) ?? 0
            self.treeInfiLigans.updateValue([["nodes" : "\(numNode)", "links" : "\(numLink)"]], forKey: "num")
        } else {
            numNode = Int(String(ligans[2][0])) ?? 0
            numLink = Int(String(ligans[2][1])) ?? 0
            self.treeInfiLigans.updateValue([["nodes" : "\(numNode)", "links" : "\(numLink)"]], forKey: "num")
        }
        //Add in dictionary coordinate all nodes
        var arrayNodeCoordinate: [[String : String]] = []
        for index in 0..<numNode {
            arrayNodeCoordinate.append(["x" : String(ligans[index + 3][0]), "y" : String(ligans[index + 3][1]), "z" : String(ligans[index + 3][2]), "name" : String(ligans[index + 3][3]), "num" : String(index + 1)])
        }
        self.treeInfiLigans.updateValue(arrayNodeCoordinate, forKey: "node")
        //Add in dictionary all links
        var arrayLink: [[String : String]] = []
        var num = 1
        for index in numNode..<numNode + numLink {
            var firstNode: Int = 0
            var secondNode: Int = 0
            if String(ligans[index + 3][0]).count > 3 {
                let count = "\(num)".count
                let str = String(ligans[index + 3][0])
                let indexFirstnum = str.index(str.startIndex, offsetBy: count)
                let fistNum = str[..<indexFirstnum]
                if Int(fistNum) == num {
                    firstNode = Int(String(ligans[index + 3][0].dropLast(str.count - count))) ?? 0
                    secondNode = Int(String(ligans[index + 3][0].dropFirst(count))) ?? 0
                } else {
                    num += 1
                    firstNode = Int(String(ligans[index + 3][0].dropLast(str.count - "\(num)".count))) ?? 0
                    secondNode = Int(String(ligans[index + 3][0].dropFirst("\(num)".count))) ?? 0
                }
                arrayLink.append(["first" : "\(firstNode)", "second" : "\(secondNode)", "link" : String(ligans[index + 3][1])])
            } else {
                num = Int(String(ligans[index + 3][0])) ?? 0
                arrayLink.append(["first" : String(ligans[index + 3][0]), "second" : String(ligans[index + 3][1]), "link" : String(ligans[index + 3][2])])
            }
        }
        self.treeInfiLigans.updateValue(arrayLink, forKey: "link")
    }
    
    func getListLigans() {
        //Request all list ligans
        requestManeger.getListLigans(completion: { [weak self] (response, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if error == nil {
                        self.listLigans = response
                        self.searchListLigans = response
                        self.tableView.reloadData()
                } else {
                    self.present(self.alertController.alertController(error!), animated: true, completion: nil)
                }
            }
        })
    }
    
    func getInfoLigan(nameLigan: String) {
        //Request info about ligan
        self.loadingIndicator.startAnimating()
        DispatchQueue.main.async {
            self.requestManeger.getInfoLigan(nameLigan: nameLigan, completion: { [weak self] ( response, error) in
                guard let self = self else { return }
                if error == nil {
//                    self.infoLigan = response
                    self.parsinginfoLigan(allInfro: response)
                    self.performSegue(withIdentifier: "ShowLagands", sender: .none)
                } else {
                    self.present(self.alertController.alertController(error!), animated: true, completion: nil)
                }
            })
            self.loadingIndicator.stopAnimating()
        }
    }
}
