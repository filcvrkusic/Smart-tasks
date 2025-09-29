//
//  TaskDetailsTableViewCell.swift
//  Smart tasks
//
//  Created by Filip on 27. 9. 2025..
//

import UIKit

class TaskDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont(name: "AmsiPro-Bold", size: 15)
            titleLabel.textColor = UIColor.softRed()
        }
    }
    
    @IBOutlet weak var dueDateTitleLabel: UILabel! {
        didSet {
            dueDateTitleLabel.text = "Due Date"
            dueDateTitleLabel.font = UIFont(name: "AmsiPro-Regular", size: 10)
            dueDateTitleLabel.textColor = UIColor.softRed()
        }
    }
    
    @IBOutlet weak var dueDateLabel: UILabel! {
        didSet {
            dueDateLabel.font = UIFont(name: "AmsiPro-Bold", size: 15)
            dueDateLabel.textColor = UIColor.softRed()
        }
    }
    
    @IBOutlet weak var daysLeftTitleLabel: UILabel! {
        didSet {
            daysLeftTitleLabel.text = "Days left"
            daysLeftTitleLabel.font = UIFont(name: "AmsiPro-Regular", size: 10)
            daysLeftTitleLabel.textColor = UIColor.softRed()
        }
    }
    
    @IBOutlet weak var daysLeftLabel: UILabel! {
        didSet {
            daysLeftLabel.font = UIFont(name: "AmsiPro-Bold", size: 15)
            daysLeftLabel.textColor = UIColor.softRed()
        }
    }

    func configure(with task: Task) {
        titleLabel.text = task.title
        
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
                    daysLeftLabel.textColor = .systemRed
                } else {
                    daysLeftLabel.text = "\(daysLeft)"
                    daysLeftLabel.textColor = UIColor(red: 239/255, green: 75/255, blue: 94/255, alpha: 1.0)
                }
            } else {
                daysLeftLabel.text = "-"
            }
        } else {
            dueDateLabel.text = "No due date"
            daysLeftLabel.text = "-"
        }
    }
}
