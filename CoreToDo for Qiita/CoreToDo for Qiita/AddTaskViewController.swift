//
//  AddTaskViewController.swift
//  CoreToDo for Qiita
//
//  Created by Masaya Hayashi on 2017/01/28.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    // MARK: -
    
    var taskCategory = "ToDo"
    
    // MARK: -
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var task: Task?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = task {
            taskTextField.text = task.name
            taskCategory = task.category!
            switch task.category! {
            case "ToDo":
                categorySegmentedControl.selectedSegmentIndex = 0
            case "Shopping":
                categorySegmentedControl.selectedSegmentIndex = 1
            case "Assignment":
                categorySegmentedControl.selectedSegmentIndex = 2
            default:
                categorySegmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    // MARK: - Actions of Buttons
    
    @IBAction func categoryChosen(_ sender: UISegmentedControl) {
        // choose category of task
        switch sender.selectedSegmentIndex {
        case 0:
            taskCategory = "ToDo"
        case 1:
            taskCategory = "Shopping"
        case 2:
            taskCategory = "Assignment"
        default:
            taskCategory = "ToDo"
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        
        let taskName = taskTextField.text
        if taskName == "" {
            dismiss(animated: true, completion: nil)
            return
        }
        
        if task == nil {
            task = Task(context: context)
        }
        
        if let task = task {
            task.name = taskName
            task.category = taskCategory
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
}
