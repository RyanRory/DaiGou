//
//  MemberViewController.swift
//  Lily
//
//  Created by 赵润声 on 17/11/30.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class MemberViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
//        let app = UIApplication.shared.delegate as! AppDelegate
//        let context = app.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Members")
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
        self.ctrls = FetchData.fetchData(entityName: "Members", predicate: nil)
        
        self.ctrls.sort{(m1, m2) -> Bool in return (m1.value(forKey: "totalconsumption") as! String?).flatMap{ Float($0) }! > (m2.value(forKey: "totalconsumption") as! String?).flatMap{ Float($0) }! }
        
        self.ctrlsel = self.ctrls
        
        for item in self.ctrls {
            var temp: [NSManagedObject] = FetchData.fetchData(entityName: "Sells", predicate: "member="+"'"+(item.value(forKey: "name") as! String)+"'")
            for i in temp {
                print((item.value(forKey: "name") as! String), i.value(forKey: "productname") as! String, i.value(forKey: "amount") as! String)
            }
        }
        
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
                if (ctrl.value(forKey: "name") as! String).range(of: searchText) != nil {
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
        let identiferStr:String = "MemberTableViewCell"
        let cell:MemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: identiferStr, for: indexPath) as! MemberTableViewCell
        
        cell.nameLabel.text = (self.ctrlsel[indexPath.row].value(forKey: "name") as! String)
        cell.totalConsumptionLabel.text = "总消费(RMB):" + (self.ctrlsel[indexPath.row].value(forKey: "totalconsumption") as! String)
        cell.recentLabel.text = (self.ctrlsel[indexPath.row].value(forKey: "recent") as! String)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordViewController") as! RecordViewController
        vc.name = (self.ctrlsel[indexPath.row].value(forKey: "name") as! String)
        vc.totalConsumption = "总消费(RMB):" + (self.ctrlsel[indexPath.row].value(forKey: "totalconsumption") as! String)
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
