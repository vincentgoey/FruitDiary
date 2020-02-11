//
//  EditFruitVC.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import UIKit

class EditFruitVC: UIViewController {
    
    var fruitEntryToBeEdited : FruitEntryModel!
    var availableFruit = [Fruit]()
    private var fruitPicker = UIPickerView()
    private var toolBar = UIToolbar()
    var showPicker = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fruitThatExistInEntry = fruitEntryToBeEdited!.fruit
        //Filter Available Fruit
        var testingFilter2 = [Int]()
        fruitThatExistInEntry.forEach { ( item ) in
            testingFilter2.append(item.fruitId)
        }
        let testingArrayFilter = Singleton.shared.availableFruits.toArray()
        self.availableFruit = testingArrayFilter.filter{!testingFilter2.contains($0.id)}
        
        self.setupNavBar()
        self.setupPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupNavBar() {
        self.title = self.fruitEntryToBeEdited.date
        
        //setup Right Navigation Button
        let imageIcon = UIImage(named: appConstant.addIcon)
        let rightButton = UIBarButtonItem(image: imageIcon,  style: .plain, target: self, action:#selector(addNewFruit))
        rightButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func setupPickerView(){
        self.fruitPicker = UIPickerView.init()
        self.fruitPicker.delegate = self
        self.fruitPicker.dataSource = self

        self.fruitPicker.contentMode = .center
        self.fruitPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Add", style: .done, target: self, action: #selector(dismissPicker))]
    }

}

extension EditFruitVC: UIPickerViewDelegate, UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.availableFruit.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.availableFruit[row].type
    }
}

extension EditFruitVC {
    
    @objc func dismissPicker() {
        
        var selectedFruit = ""
        let row = self.fruitPicker.selectedRow(inComponent: 0)
            if row == 0{
                selectedFruit = self.availableFruit[row].type
            }
        
        let alert = UIAlertController(title: selectedFruit, message: "Enter Amount", preferredStyle: .alert)

        //Add text field for amnount for fruits
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter Amount, It Must Be Numeric!"
        }

        //Grab the value from the text field
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text?.count ?? 0 > 0 {
                if Int((textField?.text)!) != nil {
                    self.addFruit(row: row, amount: Int(textField!.text!)!)
                } else {
                    self.view.endEditing(true)
                }
            } else {
                self.view.endEditing(true)
            }
        }))

        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func addNewFruit(){
        if !self.showPicker{
           self.view.addSubview(self.fruitPicker)
            self.view.addSubview(self.toolBar)
        } else {
            self.fruitPicker.removeFromSuperview()
            self.toolBar.removeFromSuperview()
        }
        self.showPicker = !self.showPicker
    }
        
    func addFruit(row: Int, amount: Int) {
        print("Amount: ", amount)
        if amount > 0 {
            // Post Api
        }
    }
    
}
