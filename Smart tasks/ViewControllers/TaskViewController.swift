//
//  TaskViewController.swift
//  Smart tasks
//
//  Created by Filip on 29. 9. 2025..
//

import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var taskTitleLabel: UILabel! {
        didSet {
            taskTitleLabel.font = UIFont(name: "AmsiPro-Bold", size: 20)
            taskTitleLabel.text = "Task Detail"
        }
    }
    
    @IBOutlet weak var dueDateTitleLabel: UILabel! {
        didSet {
            dueDateTitleLabel.text = "Due Date"
            dueDateTitleLabel.font = UIFont(name: "AmsiPro-Regular", size: 10)
        }
    }

    @IBOutlet weak var dueDateLabel: UILabel! {
        didSet {
            dueDateLabel.font = UIFont(name: "AmsiPro-Bold", size: 15)
        }
    }
    
    @IBOutlet weak var daysLeftTitleLabel: UILabel! {
        didSet {
            daysLeftTitleLabel.text = "Days left"
            daysLeftTitleLabel.font = UIFont(name: "AmsiPro-Regular", size: 10)
        }
    }
    
    @IBOutlet weak var daysLeftLabel: UILabel! {
        didSet {
            daysLeftLabel.font = UIFont(name: "AmsiPro-Bold", size: 15)
        }
    }
    
    @IBOutlet weak var commentLabel: UILabel! {
        didSet {
            commentLabel.font = UIFont(name: "AmsiPro-Bold", size: 12)
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.font = UIFont(name: "AmsiPro-Bold", size: 15)
        }
    }
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var resolveButton: UIButton!
    @IBOutlet weak var noResolveButton: UIButton!
    
    @IBOutlet weak var statusImageVIew: UIImageView!
    
    @IBOutlet weak var taskDetailLabel: UILabel! {
        didSet {
            taskDetailLabel.font = UIFont(name: "AmsiPro-Bold", size: 20)
            taskDetailLabel.text = "Task Detail"
            taskDetailLabel.textColor = .white
        }
    }
    @IBOutlet weak var previousButton: UIButton!
    
    // MARK: - Properties
    private var task: Task
    private let viewModel: TaskViewModel
    
    // MARK: - Initialization
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWithTask()
        resolveButton.addTarget(self, action: #selector(resolveButtonTapped), for: .touchUpInside)
        noResolveButton.addTarget(self, action: #selector(cantResolveButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
    }

    
    // MARK: - Orientation Control
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.orientationLock = .portrait
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.orientationLock = .all
    }
    
    // MARK: - Configuration
    private func configureWithTask() {
        taskTitleLabel.text = task.title
        
        if let description = task.description, !description.isEmpty {
            commentLabel.text = description
        } else {
            commentLabel.text = "No description provided"
        }
        
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd yyyy"
            dueDateLabel.text = formatter.string(from: dueDate)
            
            let calendar = Calendar.current
            let today = Date()
            let components = calendar.dateComponents([.day], from: today, to: dueDate)
            
            if let daysLeft = components.day {
                if daysLeft < 0 {
                    daysLeftLabel.text = "Overdue"
                } else {
                    daysLeftLabel.text = "\(daysLeft)"
                }
            } else {
                daysLeftLabel.text = "-"
            }
        } else {
            dueDateLabel.text = "No due date"
            daysLeftLabel.text = "-"
        }
        
        configureUIForStatus()
    }
    
    private func configureUIForStatus() {
        switch task.status {
        case .unresolved:
            let softRed = UIColor.softRed()
            taskTitleLabel.textColor = softRed
            dueDateTitleLabel.textColor = softRed
            dueDateLabel.textColor = softRed
            daysLeftTitleLabel.textColor = softRed
            daysLeftLabel.textColor = softRed
            commentLabel.textColor = softRed
            taskDetailLabel.textColor = softRed
            
            statusLabel.text = task.status.rawValue
            statusLabel.textColor = UIColor.lightYellow()
            
            buttonStackView.isHidden = false
            statusImageVIew.isHidden = true
            
        case .cantResolve:
            let softRed = UIColor.softRed()
            taskTitleLabel.textColor = softRed
            dueDateTitleLabel.textColor = softRed
            dueDateLabel.textColor = softRed
            daysLeftTitleLabel.textColor = softRed
            daysLeftLabel.textColor = softRed
            commentLabel.textColor = softRed
            statusLabel.textColor = softRed
            taskDetailLabel.textColor = softRed
            
            statusLabel.text = task.status.rawValue
            
            buttonStackView.isHidden = true
            statusImageVIew.isHidden = false
            statusImageVIew.image = UIImage(named: "Unresolved sign")
            
        case .resolved:
            let darkCyan = UIColor.darkCyan()
            taskTitleLabel.textColor = darkCyan
            dueDateTitleLabel.textColor = darkCyan
            dueDateLabel.textColor = darkCyan
            daysLeftTitleLabel.textColor = darkCyan
            daysLeftLabel.textColor = darkCyan
            commentLabel.textColor = darkCyan
            statusLabel.textColor = darkCyan
            taskDetailLabel.textColor = darkCyan
            
            statusLabel.text = task.status.rawValue
            
            buttonStackView.isHidden = true
            statusImageVIew.isHidden = false
            statusImageVIew.image = UIImage(named: "Resolved sign")
        }
    }
    
    // MARK: - Actions
    @objc private func previousButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func resolveButtonTapped() {
        showCommentDialog { [weak self] comment in
            guard let self = self else { return }
            self.viewModel.updateTaskStatus(taskId: self.task.id, status: .resolved, comment: comment)
            self.task.status = .resolved
            self.task.comment = comment
            self.configureWithTask()
        }
    }
    
    @objc private func cantResolveButtonTapped() {
        showCommentDialog { [weak self] comment in
            guard let self = self else { return }
            self.viewModel.updateTaskStatus(taskId: self.task.id, status: .cantResolve, comment: comment)
            self.task.status = .cantResolve
            self.task.comment = comment
            self.configureWithTask()
        }
    }
    
    private func showCommentDialog(completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "Add Comment", message: "Do you want to leave a comment?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default) { _ in
            completion(nil)
        })
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.showCommentInput(completion: completion)
        })
        
        present(alert, animated: true)
    }
    
    private func showCommentInput(completion: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "Enter Comment", message: "Please provide details about this task", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your comment here..."
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(nil)
        })
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            let comment = alert.textFields?.first?.text
            completion(comment)
        })
        
        present(alert, animated: true)
    }

}
