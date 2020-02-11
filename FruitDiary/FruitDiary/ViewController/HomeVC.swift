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
    
    private var fruitEntries = FruitEntryListViewModel()
    
    let sections = ["Section 1", "Section 2", "Section 3","Section 4","Section 5","Section 6","Section 7"]
    var rowDetails = [ExpandableData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupNavBar()
        self.loadAvailableFruits()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchHomePageData()
    }
    
    func addEntryApi() {
        print("How Many Times")
        let responseBody = Resource<[String:Any]>(url: URL(string: createEntries)!) { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String : Any]
        }

        let parameters: [String:Any] = [
            "date": "2020-09-20"
        ]
        
        Webservice().postMethod(resource: responseBody, body: parameters) { result in
            print("result: ", result!)
            let code = result?["code"] ?? 0
            
            switch (code as! Int) {
                case 200:
                    print("Success")
                default:
                    print("Faild With Some Reason, Code = \(code), Message = \(result?["message"] ?? "")")
            }
        }
    }
    
    func fetchHomePageData() {
        
        self.rowDetails.removeAll()
        
        let fruitEntriesResource = Resource<[FruitEntryModel]>(url: URL(string: getFruitEntries)!) { data in
            let fruitEntries = try? JSONDecoder().decode([FruitEntryModel].self, from: data)
            return fruitEntries
        }
        
        Webservice().load(resource: fruitEntriesResource) { result in
            self.fruitEntries.retrieveData(fruitsEntries: result ?? [])
            let dataArray = self.fruitEntries.toArray()
            
            dataArray.forEach { (item) in
                var stringArray = [String]()
                item.fruit.forEach { (singleFruit) in
                    //GET TOTAL VITAMINS
                    let vitamin = Singleton.shared.availableFruits.filter(id: singleFruit.fruitId)
                    
                    //Filter 0 fruits and negative fruits
                    if singleFruit.amount > 0 {
                        stringArray.append("\(singleFruit.fruitType), Amount: \(singleFruit.amount), Vitamins: \(singleFruit.amount * vitamin.vitamins)")
                    }
                    
                }
                
                stringArray = stringArray.sorted(by: {$0 < $1})
                let singleData = ExpandableData(isExpandable: true, titleLables: stringArray)
                self.rowDetails.append(singleData)
            }
            
            self.tableView.reloadData()
            
            if self.fruitEntries.count() > 0 {
                self.setupDeleteAllButton()
            }
        }
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
        
        let availableFruitResource = Resource<[Fruit]>(url: URL(string: getAvailableFruit)!) { data in
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
        rightButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func addNewFruitEntry(){
        let vc = AddFruitVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupDeleteAllButton() {
        let left = UIBarButtonItem(title: "Delete All",  style: .plain, target: self, action:#selector(deleteButtonTapped))
        left.tintColor = .black
        self.navigationItem.leftBarButtonItem = left
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    //UI Logic
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.fruitEntries.count() < 0 {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "No Data Available"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return self.fruitEntries.count()
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
        titleLable.text = self.fruitEntries.modelAt(section).date
        
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.backgroundColor = .yellow
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        closeButton.addTarget(self, action: #selector(handleSectionTapped), for: .touchUpInside)
        closeButton.tag = section
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 12
        
        let editButton = UIButton()
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.black, for: .normal)
        editButton.backgroundColor = .red
        editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        editButton.addTarget(self, action: #selector(handleEditButtonTapped), for: .touchUpInside)
        editButton.tag = section + 20 // Avoid duplicate tag in the views
        editButton.clipsToBounds = true
        editButton.layer.cornerRadius = 12
        
        let deleteButton = UIButton()
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .black
        deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        deleteButton.addTarget(self, action: #selector(handleDeleteButtonTapped), for: .touchUpInside)
        deleteButton.tag = section + 80 // Avoid duplicate tag in the views
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 12
        
        let contentView = UIView()
        contentView.addSubview(closeButton)
        contentView.addSubview(editButton)
        contentView.addSubview(titleLable)
        contentView.addSubview(deleteButton)
        contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        titleLable.translatesAutoresizingMaskIntoConstraints                                            = false
        titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive   = true
        titleLable.heightAnchor.constraint(equalToConstant: 34).isActive                                = true
        titleLable.widthAnchor.constraint(equalToConstant: 300).isActive                                = true
        
        closeButton.translatesAutoresizingMaskIntoConstraints                                                = false
        closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive     = true
        closeButton.heightAnchor.constraint(equalToConstant: 34).isActive                                    = true
        closeButton.widthAnchor.constraint(equalToConstant: CGFloat(appConstant.buttonWidth)).isActive       = true
        
        editButton.translatesAutoresizingMaskIntoConstraints                                            = false
        editButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: 0).isActive       = true
        editButton.heightAnchor.constraint(equalToConstant: 34).isActive                                = true
        editButton.widthAnchor.constraint(equalToConstant: CGFloat(appConstant.buttonWidth)).isActive   = true
        
        deleteButton.translatesAutoresizingMaskIntoConstraints                                            = false
        deleteButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: 0).isActive       = true
        deleteButton.heightAnchor.constraint(equalToConstant: 34).isActive                                = true
        deleteButton.widthAnchor.constraint(equalToConstant: CGFloat(appConstant.buttonWidth)).isActive   = true
        
        return contentView
    }
    
    //Buton Function
    
    @objc func handleEditButtonTapped(button: UIButton) {
        
        let section = button.tag - 20
        
//        let vc = EditFruitVC()
//        vc.fruitEntryToBeEdited = self.fruitEntries.modelAt(section)
//        self.navigationController?.pushViewController(vc, animated: true)
        
        let vc = AddFruitVC()
        vc.fruitEntry = self.fruitEntries.modelAt(section)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleDeleteButtonTapped(button: UIButton) {
        
        let section = button.tag - 80
        let seletedId = self.fruitEntries.modelAt(section).id

        guard let url = URL(string: deleteSpecificEntry+"\(seletedId)") else { return }
        Webservice().deleteMethod(url: url) { (err) in
            if err != nil {
                print("Failed To Delete")
                return
            }
            self.fetchHomePageData()
        }

    }
    
    @objc func deleteButtonTapped() {
        //Delete All Entry Api
        guard let url = URL(string: deleteAllEntry) else { return }
        Webservice().deleteMethod(url: url) { (err) in
            if err != nil {
                print("Failed To Delete")
                return
            }
            self.fetchHomePageData()
        }
    }
    
}
