//
//  HypesViewController.swift
//  Hype32
//
//  Created by Hin Wong on 3/30/20.
//  Copyright © 2020 Hin Wong. All rights reserved.
//

import UIKit

class HypesViewController: UIViewController {
    
    //MARK: - OUTLETS AND PROPERTIES
    @IBOutlet weak var hypesTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    //MARK: - LIFE CYCLE METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHypes()
        setUpViews()
    }
    
    //MARK: - CUSTOM METHODS
    
    func setUpViews() {
        self.hypesTableView.delegate = self
        self.hypesTableView.dataSource = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to see new Hypes")
        refreshControl.addTarget(self, action: #selector(loadHypes), for: .valueChanged)
        hypesTableView.addSubview(refreshControl)
    }
    
    @objc func loadHypes() {
        HypeController.shared.fetchAllHypes { (success) in
            DispatchQueue.main.async {
                if success {
                    self.updateViews()
                }
            }
        }
    }
    
    func updateViews() {
        self.hypesTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    //MARK: - ACTIONS
    @IBAction func composeButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Get Hype!", message: "What is hype may never die", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "What is hype today"
            textField.autocorrectionType = .yes
            textField.delegate = self
        }
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (_) in
            
            guard let body = alert.textFields?.first?.text, !body.isEmpty else { return }
                
            HypeController.shared.saveHype(body: body) { (success) in
                DispatchQueue.main.async {
                    if success {
                        self.updateViews()
                    }
                }
            }
        }
        alert.addAction(saveButton)
        
        let cancelButton = UIAlertAction(title: "NVM", style: .cancel)
        alert.addAction(cancelButton)
        
        present(alert, animated: true)
    }
}

//MARK: - TABLEVIEW DELEGATE AND DATA SOURCE

extension HypesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HypeController.shared.hypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hypeCell", for: indexPath)
        
        let hype = HypeController.shared.hypes[indexPath.row]
        cell.textLabel?.text = hype.body
        cell.detailTextLabel?.text = hype.timestamp.formatDate()
        
        return cell
    }
}

// MARK: - TEXTFIELD DELEGATE

extension HypesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
