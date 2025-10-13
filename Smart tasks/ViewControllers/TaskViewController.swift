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
        let displayModel = TaskDetailDisplayModel(task: task)
        let statusStyle = displayModel.statusStyle

        taskTitleLabel.text = displayModel.titleText
        dueDateLabel.text = displayModel.dueDateText
        daysLeftLabel.text = displayModel.daysLeftText
        commentLabel.text = displayModel.commentText
        statusLabel.text = displayModel.statusText

        taskTitleLabel.textColor = statusStyle.primaryColor
        dueDateTitleLabel.textColor = statusStyle.primaryColor
        dueDateLabel.textColor = statusStyle.primaryColor
        daysLeftTitleLabel.textColor = statusStyle.primaryColor
        daysLeftLabel.textColor = statusStyle.primaryColor
        commentLabel.textColor = statusStyle.primaryColor
        taskDetailLabel.textColor = statusStyle.primaryColor

        statusLabel.textColor = statusStyle.statusLabelColor

        buttonStackView.isHidden = statusStyle.buttonStackHidden
        statusImageVIew.isHidden = statusStyle.statusImageHidden
        statusImageVIew.image = statusStyle.statusImage
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
