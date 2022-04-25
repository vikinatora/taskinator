//
//  SettingsViewController.swift
//  iOSTaskinator
//
//  Created by Viktor Todorov on 14.4.22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var sideMenuBtn: UIBarButtonItem!
    @IBOutlet var showDefaultStatusBtn: UIButton!
    @IBOutlet var showDefaultStatusLabel: UILabel!
    @IBOutlet var showPersonalInfoSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Side menu
        sideMenuBtn.target = self.revealViewController()
        sideMenuBtn.action = #selector(self.revealViewController()?.revealSideMenu)
        
        // Status options
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Open", image: UIImage(systemName: "plus.app"), handler: { _ in self.changeDefaultStatus(newStatus: TaskStatus.Open)
                }),
                UIAction(title: "In Progress", image: UIImage(systemName: "plus.square.dashed"), handler: { _ in self.changeDefaultStatus(newStatus: TaskStatus.InProgress)
                }),
            ]
        }

        var demoMenu: UIMenu {
            return UIMenu(title: "Available statuses", image: nil, identifier: nil, options: [], children: menuItems)
        }

        showDefaultStatusBtn.menu = demoMenu
        showDefaultStatusBtn.showsMenuAsPrimaryAction = true
        
        // Status label
        self.changeDefaultStatus(newStatus: Settings.sharedInstance.defaultTaskStatus)
        
        // Personal info switch
        self.showPersonalInfoSwitch.isOn =  Settings.sharedInstance.showName
        self.showPersonalInfoSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
    }
    
    @objc func onSwitchValueChanged(_switch: UISwitch) {
        Settings.sharedInstance.showName = _switch.isOn
    }
    
    func changeDefaultStatus(newStatus: TaskStatus) {
        Settings.sharedInstance.defaultTaskStatus = newStatus;
        UserDefaults.standard.set(newStatus.rawValue, forKey: Settings.sharedInstance.defaultStatusKey)
        
        self.changeStautsLabelText(newStatus: newStatus)
    }
    
    func changeStautsLabelText(newStatus: TaskStatus) {
        switch newStatus {
        case .Open:
            showDefaultStatusLabel.text = newStatus.rawValue
        case .InProgress:
            showDefaultStatusLabel.text = "In Progress"
        default:
            showDefaultStatusLabel.text = newStatus.rawValue
        }

    }
}
