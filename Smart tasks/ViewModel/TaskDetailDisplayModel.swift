//
//  TaskDetailDisplayModel.swift
//  Smart tasks
//
//  Created by OpenAI Assistant on 2024.
//

import UIKit

struct TaskDetailDisplayModel {
    struct StatusStyle {
        let primaryColor: UIColor
        let statusLabelColor: UIColor
        let buttonStackHidden: Bool
        let statusImage: UIImage?
        let statusImageHidden: Bool
    }

    let titleText: String
    let dueDateText: String
    let daysLeftText: String
    let commentText: String
    let statusText: String
    let statusStyle: StatusStyle

    init(task: Task, calendar: Calendar = .current, now: Date = Date()) {
        titleText = task.title
        commentText = TaskDetailDisplayModel.commentText(from: task.comment ?? task.description)
        statusText = task.status.rawValue
        dueDateText = TaskDetailDisplayModel.dueDateText(from: task.dueDate)
        daysLeftText = TaskDetailDisplayModel.daysLeftText(from: task.dueDate, calendar: calendar, now: now)
        statusStyle = TaskDetailDisplayModel.statusStyle(for: task.status)
    }

    private static func commentText(from text: String?) -> String {
        guard let text = text, !text.isEmpty else {
            return "No description provided"
        }
        return text
    }

    private static func dueDateText(from dueDate: Date?) -> String {
        guard let dueDate = dueDate else {
            return "No due date"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        return formatter.string(from: dueDate)
    }

    private static func daysLeftText(from dueDate: Date?, calendar: Calendar, now: Date) -> String {
        guard let dueDate = dueDate else {
            return "-"
        }

        let components = calendar.dateComponents([.day], from: now, to: dueDate)
        guard let daysLeft = components.day else {
            return "-"
        }

        if daysLeft < 0 {
            return "Overdue"
        }

        return "\(daysLeft)"
    }

    private static func statusStyle(for status: Task.TaskStatus) -> StatusStyle {
        switch status {
        case .unresolved:
            let primaryColor = UIColor.softRed()
            return StatusStyle(
                primaryColor: primaryColor,
                statusLabelColor: UIColor.lightYellow(),
                buttonStackHidden: false,
                statusImage: nil,
                statusImageHidden: true
            )
        case .cantResolve:
            let primaryColor = UIColor.softRed()
            return StatusStyle(
                primaryColor: primaryColor,
                statusLabelColor: primaryColor,
                buttonStackHidden: true,
                statusImage: UIImage(named: "Unresolved sign"),
                statusImageHidden: false
            )
        case .resolved:
            let primaryColor = UIColor.darkCyan()
            return StatusStyle(
                primaryColor: primaryColor,
                statusLabelColor: primaryColor,
                buttonStackHidden: true,
                statusImage: UIImage(named: "Resolved sign"),
                statusImageHidden: false
            )
        }
    }
}
