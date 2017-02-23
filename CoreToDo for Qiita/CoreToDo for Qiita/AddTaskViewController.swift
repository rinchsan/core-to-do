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
    
    @IBOutlet var addTaskView: UIView!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var categorySegmentedControl2: UISegmentedControl!
    @IBOutlet weak var categorySegmentedControl3: UISegmentedControl!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var deleteCategoryButton: UIButton!
    @IBOutlet weak var addCategoryButton: UIButton!
    
    // MARK: -
    
    var taskCategory = "ToDo"
    var limitOfSegments: Int!
    
    // MARK: -
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var task: Task?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set limitOfSegments compatible for view
        limitOfSegments = Int(addTaskView.frame.width / 80)
        
        // configure category segmented control 1 2
        configureSegmentedControl()
        
        // set information of selected task (got from segue)
        if let task = task {
            taskTextField.text = task.name
            taskCategory = task.category!
            if let taskCategoryIndex = taskCategories.index(of: task.category!) {
                if taskCategoryIndex < limitOfSegments {
                    categorySegmentedControl.selectedSegmentIndex = taskCategoryIndex
                } else if taskCategoryIndex < 2 * limitOfSegments {
                    categorySegmentedControl2.selectedSegmentIndex = taskCategoryIndex - limitOfSegments
                    categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                } else {
                    categorySegmentedControl3.selectedSegmentIndex = taskCategoryIndex - 2 * limitOfSegments
                    categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
                }
            } else {
                categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            }
            addCategoryButton.isEnabled = false
        }
        
        taskTextField.delegate = self
        categoryTextField.delegate = self
    }
    
    // MARK: -
    
    func configureSegmentedControl() {
        if taskCategories.count > firstNumberOfTaskCategories {
            for addedCategoryIndex in firstNumberOfTaskCategories..<taskCategories.count {
                if addedCategoryIndex < limitOfSegments {
                    // insert into SegmentedControl 1 up to limitOfSegments
                    categorySegmentedControl.insertSegment(withTitle: taskCategories[addedCategoryIndex], at: addedCategoryIndex, animated: false)
                } else if addedCategoryIndex == limitOfSegments || addedCategoryIndex == limitOfSegments + 1 {
                    // reset segment title if index is 0 or 1 in SegmentedControl 2
                    categorySegmentedControl2.isEnabled = true // Enable SegmentedControl 2
                    // diable segment 1 if SegmentedControl2 have only segment 0
                    categorySegmentedControl2.setEnabled((addedCategoryIndex == limitOfSegments + 1), forSegmentAt: 1)
                    categorySegmentedControl2.setTitle(taskCategories[addedCategoryIndex], forSegmentAt: addedCategoryIndex - limitOfSegments)
                } else {
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
        deleteCategoryButton.isEnabled = true
        
        // choose category of task
        taskCategory = taskCategories[sender.selectedSegmentIndex + limitOfSegments]
        
        // unselect category segmented control 1
        categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    @IBAction func categoryChosen3(_ sender: UISegmentedControl) {
        deleteCategoryButton.isEnabled = true
        
        // choose category of task
        taskCategory = taskCategories[sender.selectedSegmentIndex + 2 * limitOfSegments]
        
        // unselect category segmented control 1 2
        categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        categorySegmentedControl2.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        // dismiss if nothing in taskTextField
        if taskTextField.text == "" {
            return
        }
        
        // make new Task object if nothing is got from segue
        if task == nil {
            task = Task(context: context)
        }
        
        // configure Task object
        if let task = task {
            task.name = taskTextField.text
            task.category = taskCategory
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewCategory(_ sender: Any) {
        // dismiss if no category is input
        if categoryTextField.text == "" {
            return
        }
        
        // alert if you have too much categories
        if taskCategories.count >= 2 * limitOfSegments {
            let alert = UIAlertController(title: "You cannot add category anymore.", message: "aaa", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // configure new AddedCategory object
            let addedCategory = AddedCategory(context: context)
            addedCategory.category = categoryTextField.text
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
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
