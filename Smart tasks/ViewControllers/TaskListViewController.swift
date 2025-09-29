//
//  TaskListViewController.swift
//  Smart tasks
//
//  Created by Filip on 29. 9. 2025..
//

import UIKit
import Combine

class TaskListViewController: UIViewController {
    @IBOutlet weak var dayLabel: UILabel! {
        didSet {
            dayLabel.font = UIFont(name: "AmsiPro-Bold", size: 20)
        }
    }
    @IBOutlet weak var nextDayButton: UIButton!
    @IBOutlet weak var previousDayButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "TaskDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskDetailsTableViewCell")
            tableView.separatorStyle = .none
            tableView.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    private let emptyStateImageView = UIImageView()
    
    private func setupUI() {
        emptyStateView.backgroundColor = .clear
        emptyStateImageView.image = UIImage(named: "Empty screen illustration")
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.numberOfLines = 0
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 20),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -30),
            emptyStateImageView.topAnchor.constraint(greaterThanOrEqualTo: emptyStateView.topAnchor, constant: 20),
            emptyStateImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            emptyStateImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 40),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Properties
    private let viewModel = TaskViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        viewModel.loadTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.$tasksForCurrentDate
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.tableView.reloadData()
                self?.updateEmptyState(tasks: tasks)
            }
            .store(in: &cancellables)
        
        viewModel.$currentDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.dayLabel.text = self?.viewModel.getDateString(for: date)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction func previousDayTapped(_ sender: Any) {
        viewModel.goToPreviousDay()
    }
    
    @IBAction func nextDayTapped(_ sender: Any) {
        viewModel.goToNextDay()
    }
    
    // MARK: - Helper Methods
    private func updateEmptyState(tasks: [Task]) {
        let hasNoTasks = tasks.isEmpty
        emptyStateView.isHidden = !hasNoTasks
        tableView.isHidden = hasNoTasks
        
        if hasNoTasks {
            let dateString = viewModel.getDateString(for: viewModel.currentDate)
            emptyStateLabel.text = "No tasks for \(dateString.lowercased())!"
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasksForCurrentDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskDetailsTableViewCell", for: indexPath) as! TaskDetailsTableViewCell
        let task = viewModel.tasksForCurrentDate[indexPath.row]
        cell.configure(with: task)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = viewModel.tasksForCurrentDate[indexPath.row]
        let detailVC = TaskViewController(task: task, viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

