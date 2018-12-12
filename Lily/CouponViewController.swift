//
//  CouponViewController.swift
//  Lily
//
//  Created by 赵润声 on 3/2/18.
//  Copyright © 2018 Lily. All rights reserved.
//

import UIKit
import CoreData

class CouponViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tView: UITableView!
    var ctrls:[NSManagedObject] = []
    var ctrlsel:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.ctrls = FetchData.fetchData(entityName: "Coupons", predicate: nil)
        
        self.ctrlsel = self.ctrls
        
        self.tView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ctrlsel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identiferStr:String = "CouponTableViewCell"
        let cell:CouponTableViewCell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! CouponTableViewCell
        
        cell.uuidLabel.text = (self.ctrlsel[indexPath.row].value(forKey: "uuid") as! String)
        cell.contentLabel.text = (self.ctrlsel[indexPath.row].value(forKey: "content") as! String)
        
        if (self.ctrls[indexPath.row].value(forKey: "expired") as! Bool || self.ctrls[indexPath.row].value(forKey: "used") as! Bool) {
            cell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    

}
