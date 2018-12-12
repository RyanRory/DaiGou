//
//  ProfitViewController.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/1.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class ProfitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var profitLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var incomeLabel: UILabel!
    @IBOutlet var tView: UITableView!
    var ctrls:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tView.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var profit:Float = 0.0
        var cost:Float = 0.0
        var income:Float = 0.0
        
        self.ctrls = FetchData.fetchData(entityName: "Batchs", predicate: nil)
        
        //UpdateData.updateSellsUUID()
        //DeleteData.deleteNoBatch()
        //UpdateData.updateItem()
//        for i in 1...43 {
//          UpdateData.updateBatchs(batch: "\(i)")
//        }
        
        for item in self.ctrls {
            cost += (item.value(forKey: "totalcost") as! String?).flatMap{ Float($0) }!
            cost += (item.value(forKey: "carriage") as! String?).flatMap{ Float($0) }!
            income += (item.value(forKey: "totalincome") as! String?).flatMap{ Float($0) } ?? 0
            profit += (item.value(forKey: "totalprofit") as! String?).flatMap{ Float($0) }!
        }
        
        self.ctrls.sort{(m1, m2) -> Bool in return (m1.value(forKey: "id") as! String?).flatMap{ Float($0) }! > (m2.value(forKey: "id") as! String?).flatMap{ Float($0) }! }
        
        self.costLabel.text = "\(cost)"
        self.profitLabel.text = "\(profit)"
        self.incomeLabel.text = "\(income)"
        
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
        let identiferStr:String = "ProfitTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! ProfitTableViewCell
        
        cell.batchLabel.text = "批次:" + (self.ctrls[indexPath.row].value(forKey: "id") as! String)
        cell.profitLabel.text = "净利润(AUD):" + (self.ctrls[indexPath.row].value(forKey: "totalprofit") as! String)
        
        if (self.ctrls[indexPath.row].value(forKey: "completed") != nil && self.ctrls[indexPath.row].value(forKey: "completed") as! Bool) {
            cell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BatchViewController") as! BatchViewController
        
        vc.batch = self.ctrls[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
