//
//  TaskViewModel.swift
//  Smart tasks
//
//  Created by Filip on 27. 9. 2025..
//

import Foundation
import Combine

struct TasksResponse: Codable {
    let tasks: [Task]
}

class TaskViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [Task] = []
    @Published var currentDate: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var tasksForCurrentDate: [Task] = []
    
    // MARK: - Private Properties
    private var allTasks: [Task] = []
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let taskStatusKey = "TaskStatuses"
    private let taskCommentsKey = "TaskComments"
    
    // MARK: - Initialization
    init() {
        loadTasks()
    }
    
    // MARK: - Public Methods
    
    func loadTasks() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://demo9877360.mockable.io/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                
                do {
                    let tasks = try decoder.decode([Task].self, from: data)
                    self?.allTasks = tasks
                    self?.loadLocalTaskStatuses()
                    self?.updateTasksForCurrentDate()
                } catch {
                    do {
                        let response = try decoder.decode(TasksResponse.self, from: data)
                        self?.allTasks = response.tasks
                        self?.loadLocalTaskStatuses()
                        self?.updateTasksForCurrentDate()
                    } catch {
                        print("Decoding error: \(error)")
                        self?.errorMessage = "Failed to parse tasks: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }
    
    func getTasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let requestedDate = calendar.startOfDay(for: date)
        
        var tasksForDate = allTasks.filter { task in
            let taskTargetDate = calendar.startOfDay(for: task.targetDate)
            
            if calendar.isDate(taskTargetDate, inSameDayAs: requestedDate) {
                return true
            }
            
            if task.status == .unresolved && taskTargetDate < requestedDate {
                if let dueDate = task.dueDate {
                    let taskDueDate = calendar.startOfDay(for: dueDate)
                    
                    if taskDueDate < today {
                        return calendar.isDate(taskDueDate, inSameDayAs: requestedDate)
                    }
                    
                    if requestedDate <= taskDueDate && calendar.isDate(requestedDate, inSameDayAs: today) {
                        return true
                    }
                } else {
                    return calendar.isDate(requestedDate, inSameDayAs: today)
                }
            }
            
            return false
        }
        
        tasksForDate.sort { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority < task2.priority
            }
            return task1.targetDate < task2.targetDate
        }
        
        return tasksForDate
    }

    func updateTasksForCurrentDate() {
        tasksForCurrentDate = getTasksForDate(currentDate)
    }
    
    func goToNextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        updateTasksForCurrentDate()
    }
    
    func goToPreviousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        updateTasksForCurrentDate()
    }
    
    func updateTaskStatus(taskId: String, status: Task.TaskStatus, comment: String? = nil) {
        guard let index = allTasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        if canUpdateTask(allTasks[index]) {
            allTasks[index].status = status
            allTasks[index].comment = comment
            
            saveTaskStatus(taskId: taskId, status: status)
            if let comment = comment {
                saveTaskComment(taskId: taskId, comment: comment)
            }
            
            updateTasksForCurrentDate()
        }
    }
    
    func canUpdateTask(_ task: Task) -> Bool {
        if task.status != .unresolved {
            return false
        }
        
        if let dueDate = task.dueDate {
            return dueDate >= Date()
        }
        
        return true
    }
    
    func getDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadLocalTaskStatuses() {
        if let statusData = userDefaults.dictionary(forKey: taskStatusKey) as? [String: String] {
            for (index, task) in allTasks.enumerated() {
                if let statusString = statusData[task.id],
                   let status = Task.TaskStatus(rawValue: statusString) {
                    allTasks[index].status = status
                }
            }
        }
        
        if let commentsData = userDefaults.dictionary(forKey: taskCommentsKey) as? [String: String] {
            for (index, task) in allTasks.enumerated() {
                if let comment = commentsData[task.id] {
                    allTasks[index].comment = comment
                }
            }
        }
    }
    
    private func saveTaskStatus(taskId: String, status: Task.TaskStatus) {
        var statusData = userDefaults.dictionary(forKey: taskStatusKey) as? [String: String] ?? [:]
        statusData[taskId] = status.rawValue
        userDefaults.set(statusData, forKey: taskStatusKey)
    }
    
    private func saveTaskComment(taskId: String, comment: String) {
        var commentsData = userDefaults.dictionary(forKey: taskCommentsKey) as? [String: String] ?? [:]
        commentsData[taskId] = comment
        userDefaults.set(commentsData, forKey: taskCommentsKey)
    }
}
