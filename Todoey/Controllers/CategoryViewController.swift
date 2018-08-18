//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Alex on 2018-08-17.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    // Access to Database
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    // Amount of rows to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    //MARK: - Data Manipulation Methods
    func saveCategories() {
        do
        {
            try context.save()
        } catch {
            print("Error saving data, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(request : NSFetchRequest<Category> = Category.fetchRequest()) {
        // Read information from SQLite
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading information, \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        // Controller to show an alert with a title after the button is pressed
        var alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        
        // Action to do once the button inside the alert is pressed
        var action = UIAlertAction(title: "Add Category", style: .default) {
            (alert) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
            
        }
        
        // Information to help user know what to place in the text field
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methods
    
    // What happens when performSeque occurs in didSelectRow method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // We know we're going to that destination VC, therefore we can cast it
        let destinationVC = segue.destination as! TodoListViewController
        
        // This allows us to tap into the selected row, and testing first because it is an optional
        if let indexPath = tableView.indexPathForSelectedRow {
            // We set the "selectedCategory" from within the TodoListViewController
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
}
