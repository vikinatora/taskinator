//
//  ViewController.swift
//  iOSTaskinator
//
//  Created by Viktor Todorov on 14.4.22.
//

import UIKit
import RealmSwift
import FacebookLogin

// TODO: MOVE ALL REALM INIT LOGIC INSICE THIS CONTROLLER
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var sideMenuBtn: UIBarButtonItem!

    let tableView = UITableView()
    var realm: Realm?
    var notificationToken: NotificationToken?
    var tasks: Results<Task>?
    var realmConfiguration: Realm.Configuration?
    var userData: User?
    var titleScreen: String = "Tasks"

    deinit {
        // Always invalidate any notification tokens when you are done with them.
        notificationToken?.invalidate()
    }
        
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        
        // Get FB Credentials using it's access token
        let credentials = Credentials.facebook(accessToken: AccessToken.current?.tokenString ?? "")

        // Log into realm using the access tokken
        app.login(credentials: credentials) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Failed to log in to MongoDB Realm: \(error)")
                case .success(let user):
                    print("Successfully logged in to MongoDB Realm using Facebook OAuth.")
                    print(user)
                    let userRealmConfiguration = user.configuration(partitionValue: "user=\(user.id)")
                    
                    self.realm = try! Realm(configuration: userRealmConfiguration)

                    // There should only be one user in my realm - that is myself
                    let usersInRealm = self.realm!.objects(User.self)
                    self.notificationToken = usersInRealm.observe { [weak self, usersInRealm] (_) in
                        self?.userData = usersInRealm.first
                        guard let tableView = self?.tableView else { return }
                        tableView.reloadData()
                    }
                    
                    
                    // Access all tasks in the realm, sorted by _id so that the ordering is defined.
                    self.tasks = self.realm!.objects(Task.self).sorted(byKeyPath: "_id")

                    if (Settings.sharedInstance.showName) {
                        self.title = "\(user.profile.firstName!)'s Tasks"
                    }

                    // Observe the tasks for changes. Hang on to the returned notification token.
                    self.notificationToken = self.tasks!.observe { [weak self] (changes) in
                        guard let tableView = self?.tableView else { return }
                        switch changes {
                        case .initial:
                            // Results are now populated and can be accessed without blocking the UI
                            tableView.reloadData()
                        case .update(_, let deletions, let insertions, let modifications):
                            // Query results have changed, so apply them to the UITableView.
                            tableView.performBatchUpdates({
                                // It's important to be sure to always update a table in this order:
                                // deletions, insertions, then updates. Otherwise, you could be unintentionally
                                // updating at the wrong index!
                                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                                    with: .automatic)
                                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                    with: .automatic)
                                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                    with: .automatic)
                            })
                        case .error(let error):
                            // An error occurred while opening the Realm file on the background worker thread
                            fatalError("\(error)")
                        }
                    }

                }
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame
        view.addSubview(tableView)

        sideMenuBtn.target = revealViewController()
        sideMenuBtn.action = #selector(revealViewController()?.revealSideMenu)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
    }
    
    
    @objc func addButtonDidClick() {
        let alertController = UIAlertController(title: "Add Task", message: "", preferredStyle: .alert)

        // When the user clicks the add button, present them with a dialog to enter the task name.
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            _ -> Void in
            let textField = alertController.textFields![0] as UITextField

            let task = Task(name: textField.text ?? "New Task")

            try! self.realm!.write {
                self.realm!.add(task)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
            textField.placeholder = "New Task Name"
        })

        // Show the dialog.
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This defines how the Tasks in the list look.
        // We want the task name on the left and some indication of its status on the right.
        let task = tasks![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = task.name
        switch task.statusEnum {
        case .Open:
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCell.AccessoryType.none
        case .InProgress:
            let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
            label.text = "In Progress"
            cell.accessoryView = label
        case .Complete:
            cell.accessoryView = nil
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // User selected a task in the table. We will present a list of actions that the user can perform on this task.
        let task = tasks![indexPath.row]

        // Create the AlertController and add its actions.
        let actionSheet: UIAlertController = UIAlertController(title: task.name, message: "Select an action", preferredStyle: .actionSheet)

        if task.statusEnum != .Open {
            actionSheet.addAction(UIAlertAction(title: "Open", style: .default) { _ in
                try! self.realm!.write {
                        task.statusEnum = .Open
                    }
                })
        }

        if task.statusEnum != .InProgress {
            actionSheet.addAction(UIAlertAction(title: "Start Progress", style: .default) { _ in
                try! self.realm!.write {
                        task.statusEnum = .InProgress
                    }
                })
        }

        if task.statusEnum != .Complete {
            actionSheet.addAction(UIAlertAction(title: "Complete", style: .default) { _ in
                try! self.realm!.write {
                        task.statusEnum = .Complete
                    }
                })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            try! self.realm!.write {
                self.realm!.delete(task)
            }

        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                actionSheet.dismiss(animated: true)
            })

        // Show the actions list.
        self.present(actionSheet, animated: true, completion: nil)
    }

}
