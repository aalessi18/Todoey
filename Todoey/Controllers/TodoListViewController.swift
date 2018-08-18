//
//  ViewController.swift
//  Todoey
//
//  Created by Alex on 2018-08-13.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import CoreData

// Using UserDefaults to persist data will not work when you try to store your own custom objects. Only Standard Data Types
// Use UserDefaults only for situations like in the playgrounds (ex: userVolume, and so on)
// Not meant to store large amounts of data


class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        // This will only happen once Category is set
        didSet {
            loadItems()
        }
    }
    
//    This would be if we wanted to use UserDefaults
//    .userDomainMask is the home directory and we save all of our data into this Items.plist
//    We can make it more flexible and efficient by creating different plists, this way the runtime is shortened
//    This is what allows persistent data beyond one instance of the application launch
//    let defaults = UserDefaults.standard
    
    // CREATE -> -C-RUD
    // Equivalent to AppDelegate by tapping into shared (singleton, current app)
    // We create the context in order to be able to tap into the persistent storage and then we retrieve its context
    // to be able to change the data. We can't work with the storage directly
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Do any additional setup after loading the view, typically from a nib.
        // Test to see if the array exists and them make that array equal to the itemArray. This way we can persist the data
        // beyond just one instance of the application
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
        
//        // Remove from permanent storage - Order matters
//        context.delete(itemArray[indexPath.row]) // If saveItems() wouldn't be there, nothing would change
//        // Remove from the array
//        itemArray.remove(at: indexPath.row)
        
        // Process of updating information
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
            // Create the objects and fill in their attributes
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            print(newItem.title)
            
            self.itemArray.append(newItem)
            
            // Save the items that were created
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
        //let encoder = PropertyListEncoder()
        
        do
        {
//            // Encode the data
//            let data = try encoder.encode(itemArray)
//            // Write the data to the plist
//            try data.write(to: dataFilePath!)
            
            // Look at temporary area and try to save in order to see if there are any errors
            try context.save()
            
        } catch {
            print("Error saving context, \(error)")
        }
        // Need to reload the tableview in order to update the TableViewController
        tableView.reloadData()
    }
    
    // "with" is simply to state that request will be the internal parameter. Providing an equal value gives it a default value
    // in case we do not provide it with a parameter
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        
//        This would be if were using encoder and decoder
//        if let data = try? Data(contentsOf: dataFilePath!) {
//
//            do {
//            let decoder = PropertyListDecoder()
//            itemArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding item array, \(error)")
//            }
//        }
        
        // MATCHES parentCategory name with selectedCategory name and keeps only the Items that match with the parentCategory
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        // Need to test if additionalPredicate is not nil
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        
        // else if it is nil, then it is only the categoryPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        // Need to specify data type that we want to retrieve. Will retrieve all of the data that is of the type specified
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching from context, \(error)")
        }
        tableView.reloadData()
    }
}

// Instead of cramming up the inheritance of the class, we establish an extension and set up
// what we need in each class we inherit from separately


// MARK: - Search Bar Methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // Need this to query data. The way it works -> searchBar.text! at moment of search replaces "%@" in order
        // to search our database of titles to see if the text exists anywhere in our database
        // HOW we want to query our database
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        // Sort the results of our search query in alphabetical order
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
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

