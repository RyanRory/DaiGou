//
//  EditViewController.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/19.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var productNameTextField: UITextField!
    @IBOutlet var productPriceTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var totalCostTextField: UITextField!
    @IBOutlet var storeTextField: UITextField!
    @IBOutlet var incomeTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    
    var data:NSManagedObject? = nil
    var pre:NSMutableDictionary = [:]
    var post:NSMutableDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.confirmButton.addTarget(self, action: #selector(updateItem), for: UIControlEvents.touchUpInside)
        
        if data != nil {
            self.nameTextField.text = data!.value(forKey: "member") as? String
            self.amountTextField.text = data!.value(forKey: "amount") as? String
            self.productNameTextField.text = data!.value(forKey: "productname") as? String
            self.productPriceTextField.text = data!.value(forKey: "productprice") as? String
            self.totalCostTextField.text = data!.value(forKey: "totalcost") as? String
            self.incomeTextField.text = data!.value(forKey: "income") as? String
            
            if (data!.value(forKey: "arrived") != nil && data!.value(forKey: "arrived") as! Bool) {
                let confirmButton = UIBarButtonItem(title:"取消收货",style:UIBarButtonItemStyle.plain,target:self,action:#selector(confirm))
                self.navigationItem.rightBarButtonItem = confirmButton
            }
            else {
                let confirmButton = UIBarButtonItem(title:"确认收货",style:UIBarButtonItemStyle.plain,target:self,action:#selector(confirm))
                self.navigationItem.rightBarButtonItem = confirmButton
            }
        }
        
        self.nameTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        self.amountTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        self.productNameTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        self.productPriceTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        self.totalCostTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        self.incomeTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        self.storeTextField.addTarget(self, action: #selector(textfieldDidChange), for: UIControlEvents.editingChanged)
        
        let products = FetchData.fetchData(entityName: "Products", predicate: "name='\(data!.value(forKey: "productname") as! String)'")
        
        for item in products {
            if (item.value(forKey: "costprice") as! String) == (data!.value(forKey: "productprice") as! String) {
                self.storeTextField.text = item.value(forKey: "store") as? String
                break
            }
        }
        pre.setValue(self.nameTextField.text, forKey: "member")
        pre.setValue(self.amountTextField.text, forKey: "amount")
        pre.setValue(self.productNameTextField.text, forKey: "productname")
        pre.setValue(self.productPriceTextField.text, forKey: "productprice")
        pre.setValue(self.totalCostTextField.text, forKey: "totalcost")
        pre.setValue(self.incomeTextField.text, forKey: "income")
        pre.setValue(self.storeTextField.text, forKey: "store")
        pre.setValue(data?.value(forKey: "uuid"), forKey: "uuid")
        pre.setValue(data?.value(forKey: "batch"), forKey: "batch")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateItem(_sender: UIButton) {
        if (self.nameTextField.text?.isEmpty)! || (self.productNameTextField.text?.isEmpty)! || (self.productPriceTextField.text?.isEmpty)! || (self.amountTextField.text?.isEmpty)! || (self.totalCostTextField.text?.isEmpty)! || (self.storeTextField.text?.isEmpty)! || (self.incomeTextField.text?.isEmpty)!{
            
        }
        else {
            post.setValue(self.nameTextField.text, forKey: "member")
            post.setValue(self.amountTextField.text, forKey: "amount")
            post.setValue(self.productNameTextField.text, forKey: "productname")
            post.setValue(self.productPriceTextField.text, forKey: "productprice")
            post.setValue(self.totalCostTextField.text, forKey: "totalcost")
            post.setValue(self.incomeTextField.text, forKey: "income")
            post.setValue(self.storeTextField.text, forKey: "store")
            
            UpdateData.updateSell(pre: pre, post: post)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func textfieldDidChange(_ textField:UITextField) {
        textField.textColor = UIColor.red
        
        if ((textField == self.totalCostTextField || textField == self.productPriceTextField || textField == self.amountTextField) && !(self.amountTextField.text?.isEmpty)! && !(self.productPriceTextField.text?.isEmpty)!) {
            self.totalCostTextField.text = "\((self.productPriceTextField.text.flatMap{ Float($0) }!)*(self.amountTextField.text.flatMap{ Float($0) }!))"
        }
    }
    
    @objc func confirm(_ sender: UIBarButtonItem) {
        UpdateData.editArrived(pre: self.data!)
        self.navigationController?.popViewController(animated: true)
    }
    

}
