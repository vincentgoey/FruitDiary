//
//  FruitCell.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import UIKit

class FruitCell: UITableViewCell {

    var fruitImageView = UIImageView()
    var fruittNameLabel = UILabel()
    var fruitSubLabel = UILabel()
    var amountTextField = UITextField()
    
    var fruitModel: Fruit! {
        didSet{
            fruittNameLabel.text    = fruitModel.type
            fruitSubLabel.text      = "vitamins: \(fruitModel.vitamins)"
            self.downloadImage(from: URL(string: domain+fruitModel.image)!)
        }
    }
    
    var addedFruits: [FruitEntryDetailsModel]! {
        didSet{
            if !addedFruits.isEmpty {
                addedFruits.forEach { (singleFruit) in
                    if singleFruit.fruitId == fruitModel.id {
                        amountTextField.text = "\(singleFruit.amount)"
                    }
                }
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(fruitImageView)
        addSubview(fruittNameLabel)
        addSubview(fruitSubLabel)
        addSubview(amountTextField)
        
        setImageConstraints()
        setLabelConstraints()
        setTextFieldConstraints()
        configureImageView()
        configureTitleLabel()
        configureTextField()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTextField() {
        amountTextField.placeholder     = "Insert Amount"
        amountTextField.borderStyle     = .roundedRect
        amountTextField.keyboardType    = .numberPad
    }
        
    func configureImageView() {
        fruitImageView.clipsToBounds      = true
    }
    
    func configureTitleLabel() {
        fruittNameLabel.numberOfLines               = 1
        fruittNameLabel.adjustsFontSizeToFitWidth   = true
        
        fruitSubLabel.numberOfLines                 = 1
        fruitSubLabel.adjustsFontSizeToFitWidth     = true
        fruitSubLabel.textColor                     = .lightGray
    }
    
    func setImageConstraints() {
        fruitImageView.translatesAutoresizingMaskIntoConstraints                                  = false
        fruitImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive                  = true
        fruitImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive    = true
        fruitImageView.heightAnchor.constraint(equalToConstant: 60).isActive                      = true
        fruitImageView.widthAnchor.constraint(equalToConstant: 60).isActive                       = true
    }
    
    func setLabelConstraints() {
        fruittNameLabel.translatesAutoresizingMaskIntoConstraints                                                   = false
        fruittNameLabel.leadingAnchor.constraint(equalTo: fruitImageView.trailingAnchor, constant: 16).isActive     = true
        fruittNameLabel.heightAnchor.constraint(equalToConstant: 30).isActive                                       = true
        fruittNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8).isActive             = true
        fruittNameLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        fruitSubLabel.translatesAutoresizingMaskIntoConstraints                                                     = false
        fruitSubLabel.topAnchor.constraint(equalTo: fruittNameLabel.bottomAnchor, constant: 0).isActive             = true
        fruitSubLabel.leadingAnchor.constraint(equalTo: fruitImageView.trailingAnchor, constant: 16).isActive       = true
        fruitSubLabel.heightAnchor.constraint(equalToConstant: 30).isActive                                         = true
        fruitSubLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    func setTextFieldConstraints() {
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        amountTextField.widthAnchor.constraint(equalToConstant: 150).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        amountTextField.leadingAnchor.constraint(equalTo: fruittNameLabel.trailingAnchor, constant: 10).isActive = true
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.fruitImageView.image = UIImage(data: data)
            }
        }
    }
    
}
