//
//  AddBatchViewController.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/1.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class AddBatchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet var tView: UITableView!
    var ctrls:[NSManagedObject] = []
    var batchID:String = ""
    var exchangeRate:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tView.tableFooterView = UIView(frame: CGRect.zero)
        tView.allowsSelectionDuringEditing = true
        tView.setEditing(true, animated: true)
        
        let confirmButton = UIBarButtonItem(title:"完成",style:UIBarButtonItemStyle.plain,target:self,action:#selector(confirm))
        self.navigationItem.rightBarButtonItem = confirmButton

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        let app = UIApplication.shared.delegate as! AppDelegate
//        let context = app.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
//        fetchRequest.predicate = NSPredicate(format:"batch='NAN'", "")
//        self.ctrls = []
//
//        do {
//            let fetchObjects = try context.fetch(fetchRequest)
//
//            for item in (fetchObjects as! [NSManagedObject]) {
//                self.ctrls.append(item)
//            }
//
//        } catch {
//            fatalError("获取数据失败:\(error)")
//        }
        super.viewWillAppear(animated)
        
        self.loadData()
        
    }
    
    func loadData() {
        self.ctrls = FetchData.fetchData(entityName: "Sells", predicate: "batch='NAN'")
        
        self.tView.reloadData()
        
        if UserDefaults.standard.string(forKey: "batchID") != nil {
            self.batchID = UserDefaults.standard.string(forKey: "batchID")!
        }
        else {
            self.batchID = "1"
        }
        
        self.exchangeRate = UserDefaults.standard.float(forKey: "exchangeRate")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ctrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identiferStr:String = "AddBatchTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! AddBatchTableViewCell
        
        cell.nameLabel.text = (self.ctrls[indexPath.row].value(forKey: "member") as! String)
        cell.productLabel.text = (self.ctrls[indexPath.row].value(forKey: "productname") as! String) + " × " + (self.ctrls[indexPath.row].value(forKey: "amount") as! String)
        
        return cell
    }
    
    @objc func confirm(_ sender: UIBarButtonItem) {
        if let selectedItems = self.tView.indexPathsForSelectedRows {
            
            let controller = UIAlertController.init(title: nil, message: "运费", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
            }
            
            let OKAction = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default) { (action) in
                let textField = (controller.textFields?.first)! as UITextField
                if !(textField.text?.isEmpty)! {
                    var totalCost:Float = 0.0
                    var totalIncome:Float = 0.0
                    
                    let app = UIApplication.shared.delegate as! AppDelegate
                    let context = app.persistentContainer.viewContext
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
                    fetchRequest.predicate = NSPredicate(format:"batch='NAN'", "")
                    do {
                        let fetchObjects = try context.fetch(fetchRequest)
                        
                        for indexPath in selectedItems {
                            for item in (fetchObjects as! [NSManagedObject]) {
                                if item == self.ctrls[indexPath.row] {
                                    item.setValue(self.batchID, forKey: "batch")
                                    totalCost += (item.value(forKey: "totalcost") as! String?).flatMap{ Float($0) }!
                                    totalIncome += (item.value(forKey: "income") as! String?).flatMap{ Float($0) }!
                                }
                            }
                        }
                        
                        let batch = NSEntityDescription.insertNewObject(forEntityName: "Batchs", into: context)
                        batch.setValue(self.batchID, forKey: "id")
                        batch.setValue(textField.text!, forKey: "carriage")
                        batch.setValue("\(totalCost)", forKey: "totalcost")
                        batch.setValue("\(totalIncome)", forKey: "totalincome")
                        let transFee = textField.text.flatMap{ Float($0) }!
                        let totalProfit = round((totalIncome/self.exchangeRate-totalCost-transFee)*100)/100
                        batch.setValue("\(totalProfit)", forKey: "totalprofit")
                        
                        try context.save()
                        
                        UserDefaults.standard.set("\((self.batchID as String?).flatMap{ Int($0) }! + 1)", forKey: "batchID")
                        
                    } catch {
                        fatalError("更新失败:\(error)")
                    }
                }
                
                self.loadData()
                if (self.ctrls.count == 0) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            
            
            //添加文本输入框
            controller.addTextField { (textfield) in
                textfield.delegate = self // 成为代理
                textfield.addTarget(self, action: #selector(self.textfieldDidChange), for: UIControlEvents.editingChanged)
            }
            
            controller.addAction(cancelAction)
            controller.addAction(OKAction)
            OKAction.isEnabled = false
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func textfieldDidChange(_ textField:UITextField) {
        let alertController = self.presentedViewController as! UIAlertController?
        if (alertController != nil) {
            let textField = alertController!.textFields!.first!
            let okAction = alertController!.actions.last!
            okAction.isEnabled = textField.text!.count > 0
        }
    }


}
