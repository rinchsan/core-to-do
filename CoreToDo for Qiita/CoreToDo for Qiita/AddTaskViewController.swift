//
//  AddTaskViewController.swift
//  CoreToDo for Qiita
//
//  Created by Masaya Hayashi on 2017/01/28.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var categorySegmentedControl2: UISegmentedControl!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var deleteCategoryButton: UIButton!
    
    // MARK: -
    
    var taskCategory = "ToDo"
    let limitOfSegments = 5
    
    // MARK: -
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var task: Task?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure category segmented control 1 2
        configureSegmentedControl()
        
        // set information of selected task (got from segue)
        if let task = task {
            taskTextField.text = task.name
            taskCategory = task.category!
            if let taskCategoryIndex = taskCategories.index(of: task.category!) {
                categorySegmentedControl.selectedSegmentIndex = taskCategoryIndex
            } else {
                categorySegmentedControl.selectedSegmentIndex = 0
            }
        }
        
        taskTextField.delegate = self
        categoryTextField.delegate = self
    }
    
    // MARK: -
    
    func configureSegmentedControl() {
        if taskCategories.count > firstNumberOfTaskCategories {
            for addedCategoryIndex in firstNumberOfTaskCategories..<taskCategories.count {
                if addedCategoryIndex < limitOfSegments {
                    categorySegmentedControl.insertSegment(withTitle: taskCategories[addedCategoryIndex], at: addedCategoryIndex, animated: false)
                }
                else if addedCategoryIndex == limitOfSegments {
                    categorySegmentedControl2.isEnabled = true
                    categorySegmentedControl2.setEnabled(false, forSegmentAt: 1)
                    categorySegmentedControl2.setTitle(taskCategories[addedCategoryIndex], forSegmentAt: 0)
                }
                else if addedCategoryIndex == limitOfSegments + 1 {
                    categorySegmentedControl2.setEnabled(true, forSegmentAt: 1)
                    categorySegmentedControl2.setTitle(taskCategories[addedCategoryIndex], forSegmentAt: 1)
                }
                else {
                    categorySegmentedControl2.insertSegment(withTitle: taskCategories[addedCategoryIndex], at: addedCategoryIndex - limitOfSegments, animated: false)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // hide keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Actions of Buttons
    
    @IBAction func categoryChosen(_ sender: UISegmentedControl) {
        // You cannot delete first three categories
        if sender.selectedSegmentIndex < firstNumberOfTaskCategories {
            deleteCategoryButton.isEnabled = false
        } else {
            deleteCategoryButton.isEnabled = true
        }
        
        // choose category of task
        taskCategory = taskCategories[sender.selectedSegmentIndex]
        
        // unselect category segmented control 2
        categorySegmentedControl2.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    @IBAction func cateogryChosen2(_ sender: UISegmentedControl) {
        // choose category of task
        taskCategory = taskCategories[sender.selectedSegmentIndex + limitOfSegments]
        
        // unselect category segmented control 1
        categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        // dismiss if nothing in taskTextField
        let taskName = taskTextField.text
        if taskName == "" {
            dismiss(animated: true, completion: nil)
            return
        }
        
        // make new Task object if nothing is got from segue
        if task == nil {
            task = Task(context: context)
        }
        
        // configure Task object
        if let task = task {
            task.name = taskName
            task.category = taskCategory
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewCategory(_ sender: Any) {
        // dismiss if no category is input
        let newCategory = categoryTextField.text
        if newCategory == "" {
            dismiss(animated: true, completion: nil)
            return
        }
        
        // configure AddedCategory object
        let addedCategory = AddedCategory(context: context)
        addedCategory.category = newCategory!
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteSelectedCategory(_ sender: Any) {
        // delete selected category from taskCategories[]
        if let deletedIndex = taskCategories.index(of: taskCategory) {
            taskCategories.remove(at: deletedIndex)
        }
        
        // delete category from core data
        let fetchRequest1: NSFetchRequest<AddedCategory> = AddedCategory.fetchRequest()
        fetchRequest1.predicate = NSPredicate(format: "category = %@", taskCategory)
        do {
            let category = try context.fetch(fetchRequest1)
            context.delete(category[0])
        } catch {
            print("Deleted Category Fetching Failed.")
        }
        
        // delete all tasks of selected category
        let fetchRequest2: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest2.predicate = NSPredicate(format: "category = %@", taskCategory)
        do {
            let tasks = try context.fetch(fetchRequest2)
            for task in tasks {
                context.delete(task)
            }
        } catch {
            print("Deleted Task Fetching Failed.")
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
}
