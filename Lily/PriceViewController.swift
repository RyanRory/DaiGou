//
//  PriceViewController.swift
//  Lily
//
//  Created by 赵润声 on 17/11/30.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class PriceViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var ctrls:[NSManagedObject] = []
    var ctrlsel:[NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tView.tableFooterView = UIView(frame: CGRect.zero)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.ctrls = FetchData.fetchData(entityName: "Products", predicate: nil)
        
        self.ctrlsel = self.ctrls
        
//        for item in self.ctrls {
//            print("\(item.value(forKey: "name")!)", "\(item.value(forKey: "costprice")!)", "\(item.value(forKey: "sellprice")!)", "\(item.value(forKey: "store")!)")
//        }
        
        self.tView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.ctrlsel = self.ctrls
        }
        else {
            self.ctrlsel = []
            for ctrl in self.ctrls {
                if (ctrl.value(forKey: "name") as! String).range(of: searchText) != nil || (ctrl.value(forKey: "costprice") as! String).range(of: searchText) != nil || (ctrl.value(forKey: "store") as! String).lowercased().range(of: searchText.lowercased()) != nil{
                    self.ctrlsel.append(ctrl)
                }
            }
        }
        self.tView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.ctrlsel = self.ctrls
        self.tView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ctrlsel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identiferStr:String = "PriceTableViewCell"
        let cell:PriceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! PriceTableViewCell
        
        cell.nameLabel.text = (self.ctrlsel[indexPath.row].value(forKey: "name") as! String)
        cell.storeLabel.text = "购买店铺:" + (self.ctrlsel[indexPath.row].value(forKey: "store") as! String)
        cell.costPriceLabel.text = "单价(AUD):" + (self.ctrlsel[indexPath.row].value(forKey: "costprice") as! String)
        cell.sellPriceLabel.text = "售价(RMB):" + (self.ctrlsel[indexPath.row].value(forKey: "sellprice") as! String)
        //print(("192.168.0.5:3000/image/"+(self.ctrlsel[indexPath.row].value(forKey: "name") as! String)))
        cell.swImageView.image = UIImage.init(named: (self.ctrlsel[indexPath.row].value(forKey: "name") as! String))
        
        return cell
    }


}
