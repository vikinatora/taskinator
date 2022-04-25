//
//  Models.swift
//  iOSTaskinator
//
//  Created by Viktor Todorov on 17.04.22.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted(primaryKey: true) var _id: String = ""
    @Persisted var name: String = ""
}

enum TaskStatus: String {
  case Open
  case InProgress
  case Complete
}

class Task: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var owner: String?
    @Persisted var status: String = ""

    var statusEnum: TaskStatus {
        get {
            return TaskStatus(rawValue: status) ?? .Open
        }
        set {
            status = newValue.rawValue
        }
    }

    convenience init(name: String) {
        self.init()
        self.name = name
        self.status = Settings.sharedInstance.defaultTaskStatus.rawValue
    }
}
