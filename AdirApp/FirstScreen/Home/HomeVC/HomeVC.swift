//
//  ViewController.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 20.10.2021.
//

import UIKit

protocol AssignmentCompleteDelegate: AnyObject {
    func quizzeComplete(quizzeId: String)
}

private enum OpenedModel {
    case first
    case second
    case none
}

class HomeVC: UIViewController {
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var workOnTheWeekCountLabel: UILabel!
    @IBOutlet private var dayWorkTableView: UITableView! {
        didSet {
            setupTableView(tableView: dayWorkTableView)
        }
    }
    
    @IBOutlet private var weekWorkTableView: UITableView! {
        didSet {
            setupTableView(tableView: weekWorkTableView)
        }
    }
    
    private var openedModel: OpenedModel = .none
    private var userModel: UserModel?
    private var firstTestModels: [AssignmentModel] = []
    private var secondTestModels: [AssignmentModel] = [] {
        didSet {
            workOnTheWeekCountLabel.text = "\(secondTestModels.count)"
        }
    }
    private var savedAnswers: [String: [String: String]] = [:]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workOnTheWeekCountLabel.text = "0"
        loadAssignments()
        userModel = UserDefaultsService.getLoggedUserModel()
        setupNameLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openedModel = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSavedAnswers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Methods
    
    private func setupNameLabel() {
        guard let name = userModel?.full_name else { return }
        nameLabel.text = "Hello, " + name
    }
    
    private func setSavedAnswers() {
        guard let answers = Store.standard.value(forKey: StoreConstKeys.answersKey.rawValue) as? [String : [String : String]] else { return }
        savedAnswers = answers
    }
    
    private func setupTableView(tableView: UITableView) {
        tableView.register(WorkTVCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 103
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
    }
    
    private func loadAssignments() {
        APIManager.getAssignments() { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(assignments):
                strongSelf.sortAssignments(assignments: assignments)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }

        APIManager.getQuizzes() { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(assignments):
                strongSelf.sortAssignments(assignments: assignments)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func sortAssignments(assignments: [AssignmentModel]) {
        for assignment in assignments {
            if let assignmentDate = assignment.dueAt {
                let assignmentDate = DateConverter.getDate(from: assignmentDate, dateFormat: DateFormat.yyyyMMddTHHmmss.rawValue) ?? Date()
                if let diff = Calendar.current.dateComponents([.hour], from: Date(), to: assignmentDate).hour {
                    var tempAssignment = assignment
                    if Calendar.current.isDateInToday(assignmentDate) || Calendar.current.isDateInTomorrow(assignmentDate) || assignmentDate < Date() {
                        if let diff = Calendar.current.dateComponents([.hour], from: Date(), to: assignmentDate).hour, diff <= 48 {
                            if assignment.locked == "False" {
                                tempAssignment.date = assignmentDate
                                firstTestModels.append(tempAssignment)
                            }
                        }
                    } else if diff > 48, diff <= 168 {
                        if assignment.locked == "False" {
                            tempAssignment.date = assignmentDate
                            secondTestModels.append(tempAssignment)
                        }
                    }
                }
            } else {
                secondTestModels.append(assignment)
            }
        }
        firstTestModels = sort(assignments: firstTestModels)
        secondTestModels = sort(assignments: secondTestModels)
        
        dayWorkTableView.reloadData()
        weekWorkTableView.reloadData()
    }
    
    func sort(assignments: [AssignmentModel]) -> [AssignmentModel] {
        var tempArray: [AssignmentModel] = []
        var undatedArray: [AssignmentModel] = []
        for assignment in assignments {
            if assignment.date != nil {
                tempArray.append(assignment)
            } else {
                undatedArray.append(assignment)
            }
        }
        var i = tempArray.count - 1
        while(i > 0) {
            var j = 0
            while(j < i) {
                if tempArray[j].date! > tempArray[j + 1].date! {
                    tempArray.swapAt(j, j + 1)
                }
                j += 1
            }
            i -= 1
        }
        tempArray.append(contentsOf: undatedArray)
        return tempArray
    }
    
    private func loadQuestions(workModel: AssignmentModel) {
        guard workModel.quizID != nil, workModel.quizID != "" else {
            openWebView(workModel: workModel)
            return
        }
        openWorkDetailsVC(workModel: workModel)
    }
    
    private func openWebView(workModel: AssignmentModel) {
        guard let urlString = workModel.htmlURL else { return }
        let vc = homeStoryboard.instantiateViewController(identifier: "AssignmentVC") as! AssignmentVC
        vc.urlString = urlString
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openWorkDetailsVC(workModel: AssignmentModel) {
        let vc = homeStoryboard.instantiateViewController(identifier: "WorkDetailsVC") as! WorkDetailsVC
        vc.workModel = workModel
        vc.completeDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case dayWorkTableView:
            return firstTestModels.count
        case weekWorkTableView:
            return secondTestModels.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WorkTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        switch tableView {
        case dayWorkTableView:
            cell.configureCell(model: firstTestModels[indexPath.row])
        case weekWorkTableView:
            cell.configureCell(model: secondTestModels[indexPath.row])
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        104
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openedModel = tableView == dayWorkTableView ? .first : .second
        loadQuestions(workModel: tableView == dayWorkTableView ? firstTestModels[indexPath.row] : secondTestModels[indexPath.row])
    }
}

// MARK: - AssignmentCompleteDelegate {
extension HomeVC: AssignmentCompleteDelegate {
    func quizzeComplete(quizzeId: String) {
        switch openedModel {
        case .first:
            firstTestModels = firstTestModels.filter { $0.quizID != quizzeId }
            dayWorkTableView.reloadData()
        case .second:
            secondTestModels = secondTestModels.filter { $0.quizID != quizzeId }
            weekWorkTableView.reloadData()
        case .none:
            break
        }
        openedModel = .none
    }
}

extension Calendar {
  private var currentDate: Date { return Date() }

  func isDateInThisWeek(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
  }

  func isDateInThisMonth(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .month)
  }

  func isDateInNextWeek(_ date: Date) -> Bool {
    guard let nextWeek = self.date(byAdding: DateComponents(weekOfYear: 1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear)
  }

  func isDateInNextMonth(_ date: Date) -> Bool {
    guard let nextMonth = self.date(byAdding: DateComponents(month: 1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextMonth, toGranularity: .month)
  }

  func isDateInFollowingMonth(_ date: Date) -> Bool {
    guard let followingMonth = self.date(byAdding: DateComponents(month: 2), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: followingMonth, toGranularity: .month)
  }
}
