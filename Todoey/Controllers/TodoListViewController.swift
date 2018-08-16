//
//  ViewController.swift
//  Todoey
//
//  Created by Alex on 2018-08-13.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

// Using UserDefaults to persist data will not work when you try to store your own custom objects. Only Standard Data Types
// Use UserDefaults only for situations like in the playgrounds (ex: userVolume, and so on)
// Not meant to store large amounts of data


class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    // .userDomainMask is the home directory and we save all of our data into this Items.plist
    // We can make it more flexible and efficient by creating different plists, this way the runtime is shortened
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
//    // This is what allows persistent data beyond one instance of the application launch
//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Test to see if the array exists and them make that array equal to the itemArray. This way we can persist the data
        // beyond just one instance of the application
        
        loadItems()
    }
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // This is to have a cell to return on our table view controller in order to generate cells as we need more
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // If true, .checkmark, else .none
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        //UI alert to append to the list
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            
            // What will happen once the user clicks the add item button
            let newItem = Item()
            newItem.title = textField.text!
            
            print(newItem.title)
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
//            // Key to retrieve the "value"
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
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
    
    // Method to encode our data in order to be able to store it - Needs to decode in order to persist in the user's Device
    // The process of Encoding and Decoding is essentially taking one data type, converting it into another, and afterwards
    // reading the now converted data type by converting it back to its initial type
    // Need to convert our data type (itemArray) into a PropertyListEncoder type in order to be able to store it in our app.
    // Then we create a PropertyListDecoder in order to convert back our encoded Data (PropertyListEncoder) as an [Item] which
    // we store again into our itemArray
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do
        {
            // Encode the data
            let data = try encoder.encode(itemArray)
            // Write the data to the plist
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding Item Array, \(error)")
        }
        // Need to reload the tableview in order to update the TableViewController
        tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            
            do {
            let decoder = PropertyListDecoder()
            itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }
}

