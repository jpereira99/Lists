//
//  ViewController.swift
//  BMSv3
//
//  Created by Jayden Pereira on 4/3/19.
//  Copyright © 2019 Jayden Pereira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var logoImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImage.image = #imageLiteral(resourceName: "Logowhite.png")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: "toTableView", sender: self)
        }
    }

}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    //var helper = CellItem(title: "test").getMockData()
    var helper = [CellItem]()
    @IBOutlet weak var table: UITableView!
    let listOfTitles = [
        "Do great things today",
        "Everything you’ve ever wanted is on the other side of fear",
        "Make each day your masterpiece",
        "Wherever you go, go with all your heart",
        "Tough times never last, but tough people do",
        "Believe and act as if it were impossible to fail",
        "Turn your wounds into wisdom",
        "Action is the foundational key to all success",
        "You must be the change you wish to see in the world"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomTitle = listOfTitles.randomElement()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: 20)!]
        self.title = /*randomTitle*/ "Do great things today"
        self.table.delegate = self
        self.table.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TableViewController.didTapAddItemButton(_:)))
        
        // Setup a notification to let us know when the app is about to close,
        // and that we should store the user items to persistence. This will call the
        // applicationDidEnterBackground() function in this class
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        do
        {
            // Try to load from persistence
            self.helper = try [CellItem].readFromPersistence()
        }
        catch let error as NSError
        {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
            {
                NSLog("No persistence file found, not necesserially an error...")
            }
            else
            {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load the to-do items!",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                NSLog("Error loading from persistence: \(error)")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helper.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoCell", for: indexPath)
        
        if indexPath.row < helper.count {
            let item = helper[indexPath.row]
            cell.textLabel?.text = item.title
            
            let accessory: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
            cell.accessoryType = accessory
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < helper.count
        {
            let item = helper[indexPath.row]
            item.done = !item.done
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if indexPath.row < helper.count
        {
            helper.remove(at: indexPath.row)
            table.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    @objc func didTapAddItemButton(_ sender: UIBarButtonItem)
    {
        // Create an alert
        let alert = UIAlertController(
            title: "New item",
            message: "Create a title for the new item",
            preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's title
        alert.addTextField(configurationHandler: nil)
        
        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text
            {
                self.addNewToDoItem(title: title)
            }
        }))
        
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addNewToDoItem(title: String)
    {
        // The index of the new item will be the current item count
        let newIndex = helper.count
        
        // Create new item and add it to the todo items list
        helper.append(CellItem(title: title))
        
        // Tell the table view a new row has been created
        table.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
    @objc public func applicationDidEnterBackground(_ notification: NSNotification) {
        do {
            try helper.writeToPersistence()
        }
        catch let error {
            NSLog("Error writing to persistence: \(error)")
        }
    }
}

