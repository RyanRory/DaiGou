//
//  DeleteData.swift
//  Lily
//
//  Created by 赵润声 on 2018/1/6.
//  Copyright © 2018年 Lily. All rights reserved.
//

import UIKit
import CoreData

class DeleteData: NSObject {
    
    class func deleteNoBatch() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Batchs")
        fetchRequest.predicate = NSPredicate(format:"id='65'")
        do {
            let fetchObjects = try context.fetch(fetchRequest)
            
            for item in (fetchObjects as! [NSManagedObject]) {
                context.delete(item)
            }
            
            try context.save()
            
            UserDefaults.standard.set("65", forKey: "batchID")
        } catch {
            fatalError("获取数据失败:\(error)")
        }
        
    }

}
