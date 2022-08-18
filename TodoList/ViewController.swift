//
//  ViewController.swift
//  TodoList
//
//  Created by 백시훈 on 2022/08/18.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    var doneButton: UIBarButtonItem?
    var tasks = [Task](){
        didSet{
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tabDoneButton))
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.loadTask()
    }
    
    @objc func tabDoneButton(){
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableview.setEditing(false, animated: true)
    }
    
    @IBAction func tabEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableview.setEditing(true, animated: true)
    }
    @IBAction func tabAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: {[weak self]_ in
            guard let title = alert.textFields?[0].text else{ return }
            let task = Task(title: title, done: false )
            self?.tasks.append(task)
            self?.tableview.reloadData()
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(registerButton)
        alert.addAction(cancelButton)
        alert.addTextField(configurationHandler: {UITextField in UITextField.placeholder = "할일을 입력해주세요."})
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTasks(){
        let data = self.tasks.map{
            [
                "title" : $0.title,
                "done" : $0.done
            ]
        }
        let userDefult = UserDefaults.standard
        userDefult.set(data, forKey: "tasks")
    }
    func loadTask(){
        let userDefult = UserDefaults.standard
        guard let data = userDefult.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //각 행의 갯수
        //필수 구현
        return self.tasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //필수 구현
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)//Cell를 재사용을 한다.
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        self.tableview.deleteRows(at: [indexPath], with: .automatic)
        if self.tasks.isEmpty{
            self.tabDoneButton()
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableview.reloadRows(at: [indexPath], with: .automatic)
    }
}
