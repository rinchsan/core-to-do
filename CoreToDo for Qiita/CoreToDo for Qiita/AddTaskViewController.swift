//
//  AddTaskViewController.swift
//  CoreToDo for Qiita
//
//  Created by Masaya Hayashi on 2017/01/28.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet private var addTaskView: UIView!
    @IBOutlet private weak var taskTextField: UITextField!
    @IBOutlet private weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet private weak var categorySegmentedControl2: UISegmentedControl!
    @IBOutlet private weak var categorySegmentedControl3: UISegmentedControl!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var addTaskButton: UIButton!
    @IBOutlet private weak var deleteCategoryButton: UIButton!
    @IBOutlet private weak var addCategoryButton: UIButton!
    @IBOutlet private weak var notificationDatePicker: UIDatePicker!
    @IBOutlet private weak var notificationDatePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var alarmButton: UIButton!
    
    // MARK: -
    
    var taskCategory = "ToDo"
    var limitOfSegments: Int!
    var notificationEnabled = false
    
    // MARK: -
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var task: Task?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        limitOfSegments = Int(addTaskView.frame.width / 80)
        
        configureSegmentedControl()
        
        if let task = task {
            setEditedTask(task)
        }
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.cancelButtonTapped(_:)))
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)
        
        taskTextField.delegate = self
        categoryTextField.delegate = self
        
        taskTextField.becomeFirstResponder()
    }
    
    // MARK: -
    
    func configureSegmentedControl() {
        if taskCategories.count <= firstNumberOfTaskCategories { return }
        
        for addedCategoryIndex in firstNumberOfTaskCategories..<taskCategories.count {
            if addedCategoryIndex < limitOfSegments {
                // insert into SegmentedControl 1 up to limitOfSegments
                categorySegmentedControl.insertSegment(withTitle: taskCategories[addedCategoryIndex], at: addedCategoryIndex, animated: false)
            } else if addedCategoryIndex == limitOfSegments || addedCategoryIndex == limitOfSegments + 1 {
                // reset segment title if index is 0 or 1 in SegmentedControl 2
                categorySegmentedControl2.isEnabled = true // Enable SegmentedControl 2
                // disable segment 1 if SegmentedControl2 has only segment 0
                categorySegmentedControl2.setEnabled((addedCategoryIndex == limitOfSegments + 1), forSegmentAt: 1)
                categorySegmentedControl2.setTitle(taskCategories[addedCategoryIndex], forSegmentAt: addedCategoryIndex - limitOfSegments)
            } else if addedCategoryIndex < 2 * limitOfSegments {
                // insert into SegmentedControl 2 up to limitOfSegments
                categorySegmentedControl2.insertSegment(withTitle: taskCategories[addedCategoryIndex], at: addedCategoryIndex - limitOfSegments, animated: false)
            } else if addedCategoryIndex == 2 * limitOfSegments || addedCategoryIndex == 2 * limitOfSegments + 1 {
                // reset segment title if index is 0 or 1 in SegmentedControl 3
                categorySegmentedControl3.isEnabled = true // Enable SegmentedControl 3
                // disable segment 1 if SegmentedControl3 has only segment 0
                categorySegmentedControl3.setEnabled((addedCategoryIndex == 2 * limitOfSegments + 1), forSegmentAt: 1)
                categorySegmentedControl3.setTitle(taskCategories[addedCategoryIndex], forSegmentAt: addedCategoryIndex - 2 * limitOfSegments)
            } else {
                // insert into SegmentedControl 3 up to limitOfSegments
                categorySegmentedControl3.insertSegment(withTitle: taskCategories[addedCategoryIndex], at: addedCategoryIndex - 2 * limitOfSegments, animated: false)
            }
        }
    }
    
    func setEditedTask(_ task: Task) {
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
        if let notifiedDate = task.notifiedAt {
            alarmButton.setImage(#imageLiteral(resourceName: "bell_on"), for: .normal)
            notificationEnabled = true
            notificationDatePickerHeight.constant = 137.0
            notificationDatePicker.setDate(notifiedDate as Date, animated: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == taskTextField {
            plusButtonTapped(addTaskButton)
        } else if textField == categoryTextField {
            addNewCategory(addCategoryButton)
        }
        
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
        categorySegmentedControl3.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    @IBAction func cateogryChosen2(_ sender: UISegmentedControl) {
        deleteCategoryButton.isEnabled = true
        
        // choose category of task
        taskCategory = taskCategories[sender.selectedSegmentIndex + limitOfSegments]
        
        // unselect category segmented control 1
        categorySegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        categorySegmentedControl3.selectedSegmentIndex = UISegmentedControlNoSegment
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
        dismissWithKeyboard()
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
            if notificationEnabled {
                task.notifiedAt = notificationDatePicker.date as NSDate?
                setNotification(task)
            } else {
                task.notifiedAt = nil
            }
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismissWithKeyboard()
    }

    func setNotification(_ task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.category ?? "Reminder"
        content.body = task.name ?? "We have reminder for you."
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: task.name ?? "Reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    @IBAction func addNewCategory(_ sender: Any) {
        // dismiss if no category is input
        if categoryTextField.text == "" {
            return
        }
        
        // alert if you have too much categories
        if taskCategories.count >= 3 * limitOfSegments {
            let alert = UIAlertController(title: "You cannot add category anymore.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // configure new AddedCategory object
            let addedCategory = AddedCategory(context: context)
            addedCategory.category = categoryTextField.text
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismissWithKeyboard()
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
        
        dismissWithKeyboard()
    }
    
    func dismissWithKeyboard() {
        if taskTextField.isFirstResponder {
            taskTextField.resignFirstResponder()
        }
        if categoryTextField.isFirstResponder {
            categoryTextField.resignFirstResponder()
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if taskTextField.isFirstResponder {
            taskTextField.resignFirstResponder()
        }
        if categoryTextField.isFirstResponder {
            categoryTextField.resignFirstResponder()
        }
    }

    @IBAction func alarmButtonTapped(_ sender: UIButton) {
        notificationEnabled = !notificationEnabled
        if notificationEnabled {
            alarmButton.setImage(#imageLiteral(resourceName: "bell_on"), for: .normal)
            self.notificationDatePickerHeight.constant = 137.0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            alarmButton.setImage(#imageLiteral(resourceName: "bell_off"), for: .normal)
            self.notificationDatePickerHeight.constant = 0.0
        }
    }
    
}
