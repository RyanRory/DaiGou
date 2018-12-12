//
//  SaveData.swift
//  Lily
//
//  Created by 赵润声 on 17/11/30.
//  Copyright © 2017年 Lily. All rights reserved.
//

import UIKit
import CoreData

class SaveData: NSObject {
    
    class func save(entityName:String, params:NSDictionary) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let item = NSEntityDescription.insertNewObject(forEntityName: "\(entityName)", into: context)
        
        for (key, value) in params {
            item.setValue(value, forKey: key as! String)
        }
        
        do {
            try context.save()
        } catch {
            fatalError("存储失败:\(error)")
        }
    }
}
