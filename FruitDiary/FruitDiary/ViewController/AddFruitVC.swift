//
//  AddFruitVC.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import UIKit

class AddFruitVC: UIViewController {
    
    var tableView = UITableView()
    struct Cells {
        static let fruitCell = "FruitCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        self.title = "Fruits"
        view.addSubview(tableView)
        
        setTableViewDelegate()
        tableView.rowHeight = 80
        tableView.register(FruitCell.self, forCellReuseIdentifier: Cells.fruitCell)
        tableView.tableFooterView = UIView()
//        tableView.refreshControl = refreshControl
        tableView.pin(to: view)
        
    }
    
    func setTableViewDelegate() {
        tableView.delegate      = self
        tableView.dataSource    = self
    }
}

extension AddFruitVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.shared.availableFruits.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.fruitCell) as! FruitCell
        cell.fruitModel = Singleton.shared.availableFruits.modelAt(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
//        let vc = ContactDetailsVC()
//        vc.addContactDelegate = self
//        vc.contactViewModel.contact = self.contactViewModels.modelAt(indexPath.row)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
