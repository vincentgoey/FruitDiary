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
    var toolBar = UIToolbar()
    var keyBoardNeedLayout: Bool = true
    var addedFruit = [FruitEntryDetailsModel]()
    var addedFruitId = [Int]()
    var fruitEntry : FruitEntryModel!
    
    struct Cells {
        static let fruitCell = "FruitCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureAddButton()
        configureToolbar()
        configureModel()
        setupDissmissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        deregisterFromKeyboardNotifications()
    }
    
    func configureAddButton() {
        let rightButton = UIBarButtonItem(title: "Edit",  style: .plain, target: self, action:#selector(addButtonTapped))
        rightButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func configureModel() {
        if fruitEntry != nil {
            addedFruit = fruitEntry!.fruit
            
            addedFruit.forEach { (singleFruit) in
                self.addedFruitId.append(singleFruit.fruitId)
            }
        }
    }
    
    func configureToolbar() {
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))]
    }
    
    func configureTableView() {
        self.title = fruitEntry.date
        view.addSubview(tableView)
        
        setTableViewDelegate()
        tableView.rowHeight = 80
        tableView.register(FruitCell.self, forCellReuseIdentifier: Cells.fruitCell)
        tableView.tableFooterView = UIView()
        tableView.pin(to: view)
        
    }
    
    func setTableViewDelegate() {
        tableView.delegate      = self
        tableView.dataSource    = self
    }
}

extension AddFruitVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.shared.availableFruits.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.fruitCell) as! FruitCell
        cell.fruitModel = Singleton.shared.availableFruits.modelAt(indexPath.row)
        cell.addedFruits = addedFruit
        cell.amountTextField.inputAccessoryView = toolBar
        cell.amountTextField.tag = indexPath.row + 1 // 0 is parent view so have to start from 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.hideKeyboard()
    }
}

extension AddFruitVC {
    
    func setupDissmissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(dismissKeyBoard(tapGestureRecognizer:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyBoard(tapGestureRecognizer: UITapGestureRecognizer){
        self.tableView.endEditing(true)
    }
    
    //Avoid Keyboards Block View
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(AddFruitVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddFruitVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        tableView.contentInset.bottom = convertedFrame.height + 50
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset.bottom = 0
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func addButtonTapped() {
        
        self.hideKeyboard()
        let totalRow = Singleton.shared.availableFruits.count() //Singleton.shared.availableFruits.count() as total rows
        var latestAddedFruitsId = [Int]()

        for index in 0...totalRow {
            if let theTextField = self.view.viewWithTag(index+1) as? UITextField {
                if !theTextField.text!.isEmpty && Int(theTextField.text!) != nil {
                    if Int(theTextField.text!) ?? 0 > 0{
                        latestAddedFruitsId.append(Singleton.shared.availableFruits.modelAt(index).id)
                        self.updateFruits(index: index, amountOfFruit: Int(theTextField.text!)!)
                    }
                }
            }
        }

        //Check Any Fruits Remove or Change to Zero
        if latestAddedFruitsId.count > 0 && self.addedFruitId.count > 0 {
            let idGoingToChangeToZero = self.addedFruitId.filter{!latestAddedFruitsId.contains($0)}
            self.updateZeroFruitToAddedFruit(ids: idGoingToChangeToZero)
        } else {
            //remove entire entry
            removeAll()
        }
        
    }
    
    func updateFruits (index: Int, amountOfFruit: Int) {

        let responseBody = Resource<[String:Any]>(url: URL(string: "\(editFruit)\(fruitEntry.id)/fruit/\(Singleton.shared.availableFruits.modelAt(index).id)/?amount=\(amountOfFruit)")!) { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String : Any]
        }

        let parameters: [String:Any] = [
            "entryId": "\(self.fruitEntry.id)",
            "fruitId": "\(Singleton.shared.availableFruits.modelAt(index).id)",
            "nrOfFruit": amountOfFruit
        ]

        Webservice().postMethod(resource: responseBody, body: parameters) { result in
            print("result: ", result!)
            let code = result?["code"] ?? 0

            switch (code as! Int) {
                case 200:
                    self.pop()
                default:
                    self.popupAlert(title: "System", message: "Faild With Some Reason, Code = \(code), Message = \(result?["message"] ?? "")", actionTitles: ["Ok"], actions:[])
            }
        }
        
    }
    
    func updateFruits (id: Int, amountOfFruit: Int) {

        //https://fruitdiary.test.themobilelife.com/api/entry/1166/fruit/2/?amount=0
        let responseBody = Resource<[String:Any]>(url: URL(string: "\(editFruit)\(fruitEntry.id)/fruit/\(id)/?amount=\(amountOfFruit)")!) { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String : Any]
        }

        let parameters: [String:Any] = [
            "entryId": "\(self.fruitEntry.id)",
            "fruitId": "\(id)",
            "nrOfFruit": amountOfFruit
        ]

        Webservice().postMethod(resource: responseBody, body: parameters) { result in
            let code = result?["code"] ?? 0

            switch (code as! Int) {
                case 200:
                    self.pop()
                default:
                    self.popupAlert(title: "System", message: "Faild With Some Reason, Code = \(code), Message = \(result?["message"] ?? "")", actionTitles: ["Ok"], actions:[])
            }
        }
        
    }
    
    func updateZeroFruitToAddedFruit(ids: [Int]) {
        ids.forEach { (id) in
            self.updateFruits(id: id, amountOfFruit: 0)
        }
    }
    
    func removeAll() {
        guard let url = URL(string: deleteAllEntry) else { return }
        Webservice().deleteMethod(url: url) { (err) in
            if err != nil {
                print("Failed To Delete")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func pop() {
        self.popupAlert(title: "System", message: " Updated! ", actionTitles: ["Ok"], actions:[{action1 in
            self.navigationController?.popViewController(animated: true)
        }])
    }
}
