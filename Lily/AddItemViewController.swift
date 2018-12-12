//
//  AddItemViewController.swift
//  Lily
//
//  Created by 赵润声 on 17/11/30.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var productTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var totalCostTextField: UITextField!
    @IBOutlet var storeTextField: UITextField!
    @IBOutlet var incomeTextField: UITextField!
    @IBOutlet var nameChooseButton: UIButton!
    @IBOutlet var productChooseButton: UIButton!
    @IBOutlet var storeChooseButton: UIButton!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var pickToolView: UIView!
    @IBOutlet var picker: UIPickerView!
    var members:[NSManagedObject] = []
    var products:[NSManagedObject] = []
    var shops:[String] = ["Coles", "My Chemist", "Pharmacy", "Woolworths", "Chemist Warehouse", "Pandora"]
    var buttonTag:Int = 0
    var firstResponderTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmButton.addTarget(self, action: #selector(addItem), for: UIControlEvents.touchUpInside)
        
        self.nameChooseButton.addTarget(self, action: #selector(pickFromData), for: UIControlEvents.touchUpInside)
        self.productChooseButton.addTarget(self, action: #selector(pickFromData), for: UIControlEvents.touchUpInside)
        self.storeChooseButton.addTarget(self, action: #selector(pickFromData), for: UIControlEvents.touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchData()
    }
    
    func getFirstLetterFromString(aString: String) -> (String) {
        
        // 注意,这里一定要转换成可变字符串
        let mutableString = NSMutableString.init(string: aString)
        // 将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        // 去掉声调(用此方法大大提高遍历的速度)
        let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
        // 将拼音首字母装换成大写
        let strPinYin = pinyinString.uppercased()
        // 截取大写首字母
        let firstString = strPinYin.substring(to: strPinYin.index(strPinYin.startIndex, offsetBy:1))
        // 判断姓名首位是否为大写字母
        let regexA = "^[A-Z]$"
        let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }
    
    func fetchData() {
//        let app = UIApplication.shared.delegate as! AppDelegate
//        let context = app.persistentContainer.viewContext
//        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName:"Members")
//        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName:"Products")
        self.members = FetchData.fetchData(entityName: "Members", predicate: nil)
        self.products = FetchData.fetchData(entityName: "Products", predicate: nil)
        
        self.members.sort{(m1, m2) -> Bool in return (getFirstLetterFromString(aString: m1.value(forKey: "name") as! String) < getFirstLetterFromString(aString: m2.value(forKey: "name") as! String))}
        
//        do {
//            let fetchObjects1 = try context.fetch(fetchRequest1)
//            let fetchObjects2 = try context.fetch(fetchRequest2)
//
//            for item in (fetchObjects1 as! [NSManagedObject]) {
//                self.members.append(item)
//            }
//
//            for item in (fetchObjects2 as! [NSManagedObject]) {
//                self.products.append(item)
//            }
//        } catch {
//            fatalError("获取数据失败:\(error)")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //PickerView Delegate & DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,numberOfRowsInComponent component: Int) -> Int{
        var numberOfRows:Int = 0
        switch self.buttonTag {
        case 1:
            numberOfRows = self.members.count
        case 2:
            numberOfRows = self.products.count
        default:
            numberOfRows = self.shops.count
        }
        return numberOfRows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title:String = ""
        switch self.buttonTag {
        case 1:
            title = self.members[row].value(forKey: "name") as! String
        case 2:
            title = self.products[row].value(forKey: "name") as! String
        default:
            title = self.shops[row]
        }
        
        return title
    }

    //AddItem Action
    @objc func addItem(_sender: UIButton) {
        if (self.nameTextField.text?.isEmpty)! || (self.productTextField.text?.isEmpty)! || (self.priceTextField.text?.isEmpty)! || (self.amountTextField.text?.isEmpty)! || (self.totalCostTextField.text?.isEmpty)! || (self.storeTextField.text?.isEmpty)! || (self.incomeTextField.text?.isEmpty)!{
            
        }
        else {
            
            let params = ["member": self.nameTextField.text!,
                          "amount": self.amountTextField.text!,
                          "productname": self.productTextField.text!,
                          "income": self.incomeTextField.text!,
                          "productprice": self.priceTextField.text!,
                          "totalcost": self.totalCostTextField.text!,
                          "batch": "NAN",
                          "arrived": false,
                          "uuid":NSUUID().uuidString.replacingOccurrences(of: "-", with: "")] as [String : Any]
            
            print(params)
            
            SaveData.save(entityName: "Sells", params:params as NSDictionary)
            
            print("save data success")
            
            UpdateData.updateMember(name: self.nameTextField.text!, cost: self.incomeTextField.text!, recent: (self.productTextField.text! + " × " + self.amountTextField.text!))
            
            print("update member success")
            
            let sellPrice = "\((self.incomeTextField.text.flatMap{ Float($0) }!)/(self.amountTextField.text.flatMap{ Float($0) }!))"
            UpdateData.updateProduct(name: self.productTextField.text!, costPrice: self.priceTextField.text!, sellPrice: sellPrice, store: self.storeTextField.text!)
            
            print("update product success")
            
            self.nameTextField.text = ""
            self.productTextField.text = ""
            self.priceTextField.text = ""
            self.amountTextField.text = ""
            self.totalCostTextField.text = ""
            self.storeTextField.text = ""
            self.incomeTextField.text = ""
            
            self.fetchData()
            
        }
        
    }
    
    //TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.firstResponderTextField = textField
        self.dismissPickToolView()
        if (textField == self.totalCostTextField && !(self.amountTextField.text?.isEmpty)! && !(self.priceTextField.text?.isEmpty)!) {
            self.totalCostTextField.text = "\((self.priceTextField.text.flatMap{ Float($0) }!)*(self.amountTextField.text.flatMap{ Float($0) }!))"
            if (self.storeTextField.text?.isEmpty)! {
                self.storeTextField.becomeFirstResponder()
            }
            else {
                self.incomeTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.nameTextField:
            self.productTextField.becomeFirstResponder()
        case self.productTextField:
            self.priceTextField.becomeFirstResponder()
        case self.priceTextField:
            self.amountTextField.becomeFirstResponder()
        case self.amountTextField:
            self.storeTextField.becomeFirstResponder()
        case self.storeTextField:
            self.incomeTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    //PickActions & Animations
    @objc func pickFromData(_ sender: UIButton) {
        if sender == self.nameChooseButton {
            self.buttonTag = 1
        }
        else if sender == self.productChooseButton {
            self.buttonTag = 2
        }
        else {
            self.buttonTag = 3
        }
        
        if self.firstResponderTextField != nil {
            self.firstResponderTextField.resignFirstResponder()
        }
        
        self.picker.reloadAllComponents()
        self.picker.selectRow(0, inComponent: 0, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showPickToolView()
        }
    }
    
    func dismissPickToolView() {
        if self.pickToolView.center.y < self.view.frame.height {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                var point:CGPoint = self.pickToolView.center
                point.y += self.pickToolView.frame.height
                self.pickToolView.center = point
            })
        }
    }
    
    func showPickToolView() {
        if self.pickToolView.center.y > self.view.frame.height {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                var point:CGPoint = self.pickToolView.center
                point.y -= self.pickToolView.frame.height
                self.pickToolView.center = point
            })
        }
    }

    @IBAction func pickCancel(_ sender: Any) {
        self.dismissPickToolView()
    }
    
    @IBAction func pickConfirm(_ sender: Any) {
        if self.buttonTag == 1 {
            self.nameTextField.text = (self.members[self.picker.selectedRow(inComponent: 0)].value(forKey: "name") as! String)
            self.productTextField.becomeFirstResponder()
        }
        else if self.buttonTag == 2 {
            self.productTextField.text = (self.products[self.picker.selectedRow(inComponent: 0)].value(forKey: "name") as! String)
            self.priceTextField.text = (self.products[self.picker.selectedRow(inComponent: 0)].value(forKey: "costprice") as! String)
            self.storeTextField.text = (self.products[self.picker.selectedRow(inComponent: 0)].value(forKey: "store") as! String)
            self.amountTextField.becomeFirstResponder()
        }
        else {
            self.storeTextField.text = self.shops[self.picker.selectedRow(inComponent: 0)]
            self.incomeTextField.becomeFirstResponder()
        }
        self.dismissPickToolView()
    }
}
