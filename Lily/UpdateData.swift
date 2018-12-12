//
//  UpdateData.swift
//  Lily
//
//  Created by 赵润声 on 17/11/30.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class UpdateData: NSObject {
    
    class func updateMember(name:String, cost:String, recent:String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Members")
        fetchRequest.predicate = NSPredicate(format:"name='\(name)'", "")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            if (fetchObjects.count == 0) {
                let member = NSEntityDescription.insertNewObject(forEntityName: "Members", into: context)
                member.setValue(name, forKey: "name")
                member.setValue(cost, forKey: "totalconsumption")
                member.setValue(recent, forKey: "recent")
            }
            else {
                let member = (fetchObjects as! [NSManagedObject])[0]
                let totalCost = (member.value(forKey: "totalconsumption") as! String?).flatMap{ Float($0) }! + (cost as String?).flatMap{ Float($0) }!
                member.setValue("\(totalCost)", forKey: "totalconsumption")
                member.setValue(recent, forKey: "recent")
            
            }
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
        
    }
    
    class func updateProduct(name:String, costPrice:String, sellPrice:String, store:String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Products")
        fetchRequest.predicate = NSPredicate(format:"name="+"'"+name+"'", "")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            var recorded:Bool = false
            
            for item in (fetchObjects as! [NSManagedObject]) {
                if ((item.value(forKey: "costprice") as! String) == costPrice && (item.value(forKey: "store") as! String) == store) {
                    recorded = true
                    break
                }
            }
            
            if (!recorded) {
                let product = NSEntityDescription.insertNewObject(forEntityName: "Products", into: context)
                product.setValue(name, forKey: "name")
                product.setValue(costPrice, forKey: "costprice")
                product.setValue(sellPrice, forKey: "sellprice")
                product.setValue(store, forKey: "store")
            }
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }

    }
    
    class func updateSell(pre:NSDictionary, post:NSDictionary) {
        func updateBatch(batch:String) {
            var totalCost:Float = 0.0
            var totalIncome:Float = 0.0
            
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext
            let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName:"Batchs")
            let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
            fetchRequest1.predicate = NSPredicate(format:"id=\(batch)")
            fetchRequest2.predicate = NSPredicate(format:"batch=\(batch)")
            
            do {
                let fetchObjects1 = try context.fetch(fetchRequest1)
                let fetchObjects2 = try context.fetch(fetchRequest2)
                let batch = (fetchObjects1 as! [NSManagedObject])[0]
                
                for item in (fetchObjects2 as! [NSManagedObject]) {
                    totalCost += (item.value(forKey: "totalcost") as! String?).flatMap{ Float($0) }!
                    totalIncome += (item.value(forKey: "income") as! String?).flatMap{ Float($0) }!
                }
                
                batch.setValue("\(totalCost)", forKey: "totalcost")
                batch.setValue("\(totalIncome)", forKey: "totalincome")
                let transFee = (batch.value(forKey: "carriage") as! String?).flatMap{ Float($0) }!
                let exchangeRate = UserDefaults.standard.float(forKey: "exchangeRate")
                let totalProfit = round((totalIncome/exchangeRate-totalCost-transFee)*100)/100
                batch.setValue("\(totalProfit)", forKey: "totalprofit")
                
                try context.save()
                
            } catch {
                fatalError("更新失败:\(error)")
            }
        }
        
        func updateMember(pre:NSDictionary, post:NSDictionary) {
            print("update member start!!!!!")
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Members")
            fetchRequest.predicate = NSPredicate(format:"name='\((pre.value(forKey: "member") as! String))'")
            do {
                let fetchObjects = try context.fetch(fetchRequest)
                let member = (fetchObjects as! [NSManagedObject])[0]
                var totalCost = (member.value(forKey: "totalconsumption") as! String?).flatMap{ Float($0) }!
                totalCost -= (pre.value(forKey: "income") as! String?).flatMap{ Float($0) }!
                member.setValue("\(totalCost)", forKey: "totalconsumption")
                try context.save()
            } catch {
                fatalError("更新失败:\(error)")
            }
            
            fetchRequest.predicate = NSPredicate(format:"name='\((post.value(forKey: "member") as! String))'")
            do {
                let fetchObjects = try context.fetch(fetchRequest)
                if (fetchObjects as! [NSManagedObject]).count > 0 {
                    print("member found!!!!!!")
                    let member = (fetchObjects as! [NSManagedObject])[0]
                    var totalCost = (member.value(forKey: "totalconsumption") as! String?).flatMap{ Float($0) }!
                    totalCost += (post.value(forKey: "income") as! String?).flatMap{ Float($0) }!
                    member.setValue("\(totalCost)", forKey: "totalconsumption")
                    var recent = member.value(forKey: "recent") as! String
                    if recent.hasPrefix(post.value(forKey: "productname") as! String) {
                        recent = (post.value(forKey: "productname") as! String) + " × " + (post.value(forKey: "amount") as! String)
                        member.setValue(recent, forKey: "recent")
                    }
                }
                else {
                    print("add new member!!!!!")
                    print(pre)
                    print(post)
                    let member = NSEntityDescription.insertNewObject(forEntityName: "Members", into: context)
                    let name = post.value(forKey: "member") as! String
                    let cost = post.value(forKey: "income") as! String
                    let recent = (post.value(forKey: "productname") as! String) + " × " + (post.value(forKey: "amount") as! String)
                    member.setValue(name, forKey: "name")
                    member.setValue(cost, forKey: "totalconsumption")
                    member.setValue(recent, forKey: "recent")
                }
                try context.save()
            } catch {
                fatalError("更新失败:\(error)")
            }
            
        }
        
        func updateProduct(pre:NSDictionary, post:NSDictionary) {
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Products")
            fetchRequest.predicate = NSPredicate(format:"name="+"'\(pre.value(forKey: "productname")!)'", "")
            do {
                let fetchObjects = try context.fetch(fetchRequest)
                
                for item in (fetchObjects as! [NSManagedObject]) {
                    if ((item.value(forKey: "costprice") as! String) == (pre.value(forKey: "productprice") as! String) && (item.value(forKey: "store") as! String) == (pre.value(forKey: "store") as! String)) {
                        item.setValue(post.value(forKey: "productname"), forKey: "name")
                        item.setValue(post.value(forKey: "productprice"), forKey: "costprice")
                        let sellPrice = "\(((post.value(forKey: "income") as! String?).flatMap{ Float($0) }!)/((post.value(forKey: "amount") as! String?).flatMap{ Float($0) }!))"
                        item.setValue(sellPrice, forKey: "sellprice")
                        item.setValue(post.value(forKey: "store"), forKey: "store")
                        break
                        }
                    }
                
                try context.save()
                
            } catch {
                fatalError("更新失败:\(error)")
            }
        }
        
        print("update sell start!!!!!")
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
        fetchRequest.predicate = NSPredicate(format:"uuid='\(pre.value(forKey: "uuid") as! String)'")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            let item = (fetchObjects as! [NSManagedObject])[0]
            for (key, value) in post {
                if (key as! String) != "store" {
                    item.setValue(value, forKey: key as! String)
                }
            }
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
        
        updateBatch(batch: (pre.value(forKey: "batch") as! String))
        updateMember(pre: pre, post: post)
        updateProduct(pre: pre, post: post)
    }
    
    class func editArrived(pre:NSManagedObject) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
        fetchRequest.predicate = NSPredicate(format:"uuid='\(pre.value(forKey: "uuid") as! String)'")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            let item = (fetchObjects as! [NSManagedObject])[0]
            print(item, "found!!!!")
            let arrived = item.value(forKey: "arrived")
            if arrived != nil && arrived as! Bool {
                item.setValue(false, forKey: "arrived")
            }
            else {
                item.setValue(true, forKey: "arrived")
            }
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
    }
    
    class func updateSellsUUID() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            for item in (fetchObjects as! [NSManagedObject]) {
                item.setValue(NSUUID().uuidString.replacingOccurrences(of: "-", with: ""), forKey: "uuid")
                item.setValue(false, forKey: "arrived")
            }
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
        
    }
    
    class func editUsed(uuid:String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Coupons")
        fetchRequest.predicate = NSPredicate(format:"uuid='\(uuid)'")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            let item = (fetchObjects as! [NSManagedObject])[0]
            print(item, "found!!!!")
            let arrived = item.value(forKey: "used")
            if arrived != nil && arrived as! Bool {
                item.setValue(false, forKey: "used")
            }
            else {
                item.setValue(true, forKey: "used")
            }
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
    }
    
////////////////////////////////////////////////////////////////////////////////////////
    
    class func updateItem() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
        fetchRequest.predicate = NSPredicate(format:"batch='37'")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            for item in (fetchObjects as! [NSManagedObject]) {
                
                item.setValue("493", forKey: "income")
            }
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
    }
    
    class func updateBatch(batch: String, carriage: String?) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Batchs")
        fetchRequest.predicate = NSPredicate(format:"id='\(batch)'")

        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            let batch = (fetchObjects as! [NSManagedObject])[0]
            let exchangeRate = UserDefaults.standard.float(forKey: "exchangeRate")
            let transFee = carriage.flatMap{ Float($0) }!
            let totalIncome = (batch.value(forKey: "totalincome") as! String?).flatMap{ Float($0) }!
            let totalCost = (batch.value(forKey: "totalcost") as! String?).flatMap{ Float($0) }!
            let totalProfit = round((totalIncome/exchangeRate-totalCost-transFee)*100)/100
            batch.setValue("\(totalProfit)", forKey: "totalprofit")
            batch.setValue(carriage, forKey: "carriage")
            
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
    }
    
///////////////////////////////////////////////////////////////////////////////////////////
    class func updateTotalConsumption(name: String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Sells")
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName:"Members")
        fetchRequest.predicate = NSPredicate(format:"member='\(name)'")
        fetchRequest2.predicate = NSPredicate(format:"name='\(name)'")
        
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            let fetchObjects2 = try context.fetch(fetchRequest2)
            
            let member = (fetchObjects2 as! [NSManagedObject])[0]
            var totalConsumption: Float = 0.0
            for item in (fetchObjects as! [NSManagedObject]) {
                totalConsumption += (item.value(forKey: "income") as? String).flatMap{ Float($0) }!
            }
            
            member.setValue("\(totalConsumption)", forKey: "totalconsumption")
            try context.save()
            
        } catch {
            fatalError("更新失败:\(error)")
        }
    }
}
