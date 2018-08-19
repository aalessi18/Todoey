//
//  ViewController.swift
//  Todoey
//
//  Created by Alex on 2018-08-13.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import RealmSwift

// Using UserDefaults to persist data will not work when you try to store your own custom objects. Only Standard Data Types
// Use UserDefaults only for situations like in the playgrounds (ex: userVolume, and so on)
// Not meant to store large amounts of data


class TodoListViewController: UITableViewController {
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        // This will only happen once Category is set
        didSet {
            loadItems()
        }
    }
    
    // CREATE -> -C-RUD
    // Equivalent to AppDelegate by tapping into shared (singleton, current app)
    // We create the context in order to be able to tap into the persistent storage and then we retrieve its context
    // to be able to change the data. We can't work with the storage directly
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Do any additional setup after loading the view, typically from a nib.
        // Test to see if the array exists and them make that array equal to the itemArray. This way we can persist the data
        // beyond just one instance of the application
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // This is to have a cell to return on our table view controller in order to generate cells as we need more
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            // If true, .checkmark, else .none
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // check if todoItem is not nil
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving status, \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        //UI alert to append to the list
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            // Check is nil
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        // What will happen once the user clicks the add item button
                        // Create the objects and fill in their attributes
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        // Using currentCategory since during runtime, we know it is not an optional anymore. However,
                        // using selectedCategory instead, the compiler would still ask us to unwrap it
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "Add New Item"
            textField = alertTextField
        }
        
        // Attach the action to the alert controller
        alert.addAction(action)
        
        //Show the alert
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods
    
    func loadItems()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

// Instead of cramming up the inheritance of the class, we establish an extension and set up
// what we need in each class we inherit from separately


// MARK: - Search Bar Methods
extension TodoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    // Gets triggered when the user changes what is in the search bar (letter by letter) as well as when it becomes empty
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            // Assigns different work items to different threads

            // While the background is dismissing information, we want our keyboard and selection to be dismissed in the
            // foreground (main thread), this way everything is getting dismissed while the background is updating the view as well
            // In order to do so, we need to manually tap into the main thread, orelse the application would only remove the keyboard
            // and selection after the background updating was complete.
            DispatchQueue.main.async {
                // Should no longer be the element that is currently selected - cursor and keyboard go away
                searchBar.resignFirstResponder()
            }
        }
    }
}

