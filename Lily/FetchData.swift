//
//  FetchData.swift
//  Lily
//
//  Created by 赵润声 on 2017/12/19.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class FetchData: NSObject {
    
    class func fetchData(entityName: String, predicate: String?) -> [NSManagedObject] {
        var ctrls:[NSManagedObject] = []
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:entityName)
        if predicate != nil {
            fetchRequest.predicate = NSPredicate(format:predicate!, "")
        }
        
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            for item in (fetchObjects as! [NSManagedObject]) {
                ctrls.append(item)
                //print(item)
                if entityName == "Sells" {
                    //print("\(item.value(forKey: "member")!)", "\(item.value(forKey: "productname")!)", "\(item.value(forKey: "productprice")!)", "\(item.value(forKey: "amount")!)", "\(item.value(forKey: "totalcost")!)", "\(item.value(forKey: "income")!)", "\(item.value(forKey: "arrived")!)", "\(item.value(forKey: "uuid")!)")
                }
            }
        } catch {
            fatalError("获取数据失败:\(error)")
        }
        
        return ctrls
    }

}
