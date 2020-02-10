//
//  HomeVC.swift
//  FruitDiary
//
//  Created by Kai Xuan on 09/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import UIKit

struct ExpandableData {
    var isExpandable: Bool
    var titleLables: [String]
}

class HomeVC: UIViewController {
    
    var tableView = UITableView()
    struct Cells {
        static let cell = "Cell"
    }
    
    let sections = ["Section 1", "Section 2", "Section 3","Section 4","Section 5","Section 6","Section 7"]
    var rowDetails = [
        ExpandableData(isExpandable: true, titleLables: ["hello", "world"]),
        ExpandableData(isExpandable: true, titleLables: ["lalala", "lala", "la"]),
        ExpandableData(isExpandable: true, titleLables: ["lalala", "lala", "la"]),
        ExpandableData(isExpandable: true, titleLables: ["lalala", "lala", "la"]),
        ExpandableData(isExpandable: true, titleLables: ["lalala", "lala", "la"]),
        ExpandableData(isExpandable: true, titleLables: ["lalala", "lala", "la"]),
        ExpandableData(isExpandable: true, titleLables: ["Testing 1", "Testing 2"]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupNavBar()
        self.loadAvailableFruits()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //call data
    }
    
    func configureTableView() {
        self.title = "Fruits"
        view.addSubview(tableView)
        
        setTableViewDelegate()
        tableView.rowHeight = 40
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cells.cell)
//        tableView.refreshControl = refreshControl
        tableView.pin(to: view)
        
    }
        
    func setTableViewDelegate() {
        tableView.delegate      = self
        tableView.dataSource    = self
    }
    
    func loadAvailableFruits() {
        
        let availableFruitResource = Resource<[Fruit]>(url: URL(string: domain+getAvailableFruit)!) { data in
            let availableFruits = try? JSONDecoder().decode([Fruit].self, from: data)
            return availableFruits
        }
                
        Webservice().load(resource: availableFruitResource) { result in
            Singleton.shared.availableFruits.retrieveData(fruits: result ?? [])
        }
        
    }
    
    func setupNavBar() {
        self.title = "Fruit Diary"
        
        //setup Right Navigation Button
        let imageIcon = UIImage(named: appConstant.addIcon)
        let rightButton = UIBarButtonItem(image: imageIcon,  style: .plain, target: self, action:#selector(addNewFruitEntry))
        rightButton.tintColor = hexStringToUIColor(hex: appConstant.themeColor)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func addNewFruitEntry(){
        let vc = AddFruitVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.sections.count < 0 {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return self.sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let contentView = self.setupSectionHeader(section: section)
        return contentView
    }
    
    @objc func handleSectionTapped(button: UIButton) {
        
        let section = button.tag
        var indexPaths = [IndexPath]()

        for row in rowDetails[section].titleLables.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        self.rowDetails[section].isExpandable = !self.rowDetails[section].isExpandable
        
        button.setTitle(!self.rowDetails[section].isExpandable ? "Open" : "Close", for: .normal)
        
        if self.rowDetails[section].isExpandable {
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.rowDetails[section].isExpandable {
            return 0
        }
        return self.rowDetails[section].titleLables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.cell, for: indexPath)
        cell.textLabel?.text = self.rowDetails[indexPath.section].titleLables[indexPath.row]
        cell.imageView?.backgroundColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setupSectionHeader(section:Int) -> UIView {
        let titleLable = UILabel()
        titleLable.text = self.sections[section]
        
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSectionTapped), for: .touchUpInside)
        button.tag = section
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        
        let editButton = UIButton()
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.black, for: .normal)
        editButton.backgroundColor = .red
        editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        editButton.addTarget(self, action: #selector(handleSectionTapped), for: .touchUpInside)
        editButton.clipsToBounds = true
        editButton.layer.cornerRadius = 16
        
        let contentView = UIView()
        contentView.addSubview(button)
        contentView.addSubview(editButton)
        contentView.addSubview(titleLable)
        contentView.backgroundColor = .lightGray
        
        titleLable.translatesAutoresizingMaskIntoConstraints                                  = false
        titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive    = true
        titleLable.heightAnchor.constraint(equalToConstant: 34).isActive                      = true
        titleLable.widthAnchor.constraint(equalToConstant: 300).isActive                       = true
        
        button.translatesAutoresizingMaskIntoConstraints                                  = false
        button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive    = true
        button.heightAnchor.constraint(equalToConstant: 34).isActive                      = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive                       = true
        
        editButton.translatesAutoresizingMaskIntoConstraints                                  = false
        editButton.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: 0).isActive    = true
        editButton.heightAnchor.constraint(equalToConstant: 34).isActive                      = true
        editButton.widthAnchor.constraint(equalToConstant: 80).isActive                       = true
        
        return contentView
    }
}
