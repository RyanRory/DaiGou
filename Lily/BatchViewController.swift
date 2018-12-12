//
//  BatchViewController.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/1.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class BatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var tView: UITableView!
    @IBOutlet var batchNoLabel: UILabel!
    @IBOutlet var carriageLabel: UILabel!
    @IBOutlet var profitLabel: UILabel!
    var ctrls:[NSManagedObject] = []
    var batch:NSManagedObject = NSManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.batchNoLabel.text = "批次:" + (self.batch.value(forKey: "id") as! String)
//        self.carriageLabel.text = "运费:" + (self.batch.value(forKey: "carriage") as! String)
//        self.profitLabel.text = "净利润(AUD):" + (self.batch.value(forKey: "totalprofit") as! String)
        
        tView.tableFooterView = UIView(frame: CGRect.zero)
        
        let confirmButton = UIBarButtonItem(title:"修改运费",style:UIBarButtonItemStyle.plain,target:self,action:#selector(confirm))
        self.navigationItem.rightBarButtonItem = confirmButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ctrls = FetchData.fetchData(entityName: "Sells", predicate: "batch='\((self.batch.value(forKey: "id") as! String))'")
        
        var completed:Bool = true
        for item in self.ctrls {
            if !(item.value(forKey: "arrived") as! Bool) {
                completed = false
                break
            }
        }
        
        self.tView.reloadData()
        
        self.loadBatch(completed: completed)
    }
    
    func loadBatch(completed:Bool) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Batchs")
        fetchRequest.predicate = NSPredicate(format:"id='\((self.batch.value(forKey: "id") as! String))'")
        
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            self.batch = (fetchObjects as! [NSManagedObject])[0]
            self.batchNoLabel.text = "批次:" + (self.batch.value(forKey: "id") as! String)
            self.carriageLabel.text = "运费:" + (self.batch.value(forKey: "carriage") as! String)
            self.profitLabel.text = "净利润(AUD):" + (self.batch.value(forKey: "totalprofit") as! String)
            
            self.batch.setValue(completed, forKey: "completed")
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ctrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identiferStr:String = "BatchTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! BatchTableViewCell
        
        cell.nameLabel.text = (self.ctrls[indexPath.row].value(forKey: "member") as! String)
        cell.productLabel.text = (self.ctrls[indexPath.row].value(forKey: "productname") as! String) + " × " + (self.ctrls[indexPath.row].value(forKey: "amount") as! String)
        cell.incomeLabel.text = "收款(RMB):" + (self.ctrls[indexPath.row].value(forKey: "income") as! String)
        
        if (self.ctrls[indexPath.row].value(forKey: "arrived") != nil && self.ctrls[indexPath.row].value(forKey: "arrived") as! Bool) {
            cell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        vc.data = self.ctrls[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func confirm(_ sender: UIBarButtonItem) {
        let controller = UIAlertController.init(title: nil, message: "运费", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
        }
        
        let OKAction = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default) { (action) in
            let textField = (controller.textFields?.first)! as UITextField
            if !(textField.text?.isEmpty)! {
                UpdateData.updateBatch(batch: (self.batch.value(forKey: "id") as! String), carriage: textField.text)
            }
            
            self.loadBatch(completed: (self.batch.value(forKey: "completed") as! Bool))
            
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
    
    @objc func textfieldDidChange(_ textField:UITextField) {
        let alertController = self.presentedViewController as! UIAlertController?
        if (alertController != nil) {
            let textField = alertController!.textFields!.first!
            let okAction = alertController!.actions.last!
            okAction.isEnabled = textField.text!.count > 0
        }
    }

}
