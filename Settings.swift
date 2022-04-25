//
//  Settings.swift
//  iOSTaskinator
//
//  Created by Viktor Todorov on 25.04.22.
//

import Foundation

class Settings {
    static let sharedInstance = Settings()
    
    public let showNameKey = "TskShowName";
    public let defaultStatusKey = "tskDefaultStatus";
    
    public var showName = true;
    public var defaultTaskStatus = TaskStatus.Open
    
    private init(){
        let defaults = UserDefaults.standard
        self.showName = defaults.bool(forKey: self.showNameKey);
        
        let rawValue = TaskStatus(rawValue: defaults.string(forKey: self.defaultStatusKey) ?? TaskStatus.Open.rawValue)
        
        self.defaultTaskStatus = rawValue!
    }

}
