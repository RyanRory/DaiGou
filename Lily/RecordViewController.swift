//
//  RecordViewController.swift
//  Lily
//
//  Created by 赵润声 on 17/12/1.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class RecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var totalConsumptionLabel: UILabel!
    @IBOutlet var tView: UITableView!
    var ctrls:[NSManagedObject] = []
    var name:String = ""
    var totalConsumption:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = self.name
        self.totalConsumptionLabel.text = self.totalConsumption
        
        tView.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let app = UIApplication.shared.delegate as! AppDelegate
//        let context = app.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
//        fetchRequest.predicate = NSPredicate(format:"member="+"'"+self.name+"'", "")
//        self.ctrls = []
//
//        do {
//            let fetchObjects = try context.fetch(fetchRequest)
//
//            for member in (fetchObjects as! [NSManagedObject]) {
//                self.ctrls.append(member)
//            }
//        } catch {
//            fatalError("获取数据失败:\(error)")
//        }
        
        self.ctrls = FetchData.fetchData(entityName: "Sells", predicate: "member="+"'"+self.name+"'")
        
        self.ctrls.sort{(m1, m2) -> Bool in return (m1.value(forKey: "batch") as! String?).flatMap{ Float($0) }! > (m2.value(forKey: "batch") as! String?).flatMap{ Float($0) }! }

        for item in self.ctrls {
            print(self.name, item.value(forKey: "productname") as! String, item.value(forKey: "amount") as! String)
        }
        
        UpdateData.updateTotalConsumption(name: self.name)
        
        self.tView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ctrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identiferStr:String = "RecordTableViewCell"
        let cell:RecordTableViewCell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! RecordTableViewCell
        
        cell.productNameLabel.text = (self.ctrls[indexPath.row].value(forKey: "productname") as! String)
        cell.batchLabel.text = "批次:" + (self.ctrls[indexPath.row].value(forKey: "batch") as! String)
        cell.amountLabel.text = "数量:" + (self.ctrls[indexPath.row].value(forKey: "amount") as! String)
        cell.costPriceLabel.text = "单价(AUD):" + (self.ctrls[indexPath.row].value(forKey: "productprice") as! String)
        cell.paidLabel.text = "付款金额(RMB):" + (self.ctrls[indexPath.row].value(forKey: "income") as! String)
        
        print(cell.productNameLabel.text!, cell.batchLabel.text!, cell.amountLabel.text!, cell.costPriceLabel.text!, cell.paidLabel.text!)
        
        return cell
    }


}
