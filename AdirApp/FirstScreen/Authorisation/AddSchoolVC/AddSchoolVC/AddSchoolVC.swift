//
//  AddSchoolVC.swift
//  AdirApp
//
//  Created by iMac1 on 09.02.2022.
//

import UIKit

protocol AddSchoolDelegate: AnyObject {
    func school(model: SchoolModel)
}

final class AddSchoolVC: BaseVC {
    
    private struct Constants {
        static let schoolTVCellStandardHeight: CGFloat = 108
    }
    
    @IBOutlet private var mainTitleLabel: UILabel! {
        didSet{
            mainTitleLabel.text = "What school do you go to?"
        }
    }
    @IBOutlet private var schoolsTableView: UITableView! {
        didSet{
            schoolsTableView.register(SchoolTVCell.self)
            schoolsTableView.delegate = self
            schoolsTableView.dataSource = self
            schoolsTableView.allowsSelection = true
        }
    }
    @IBOutlet private var schoolTableViewHightConstraint: NSLayoutConstraint!
    
    var registrationModel: RegistrationModel?
    
    private var schools: [SchoolModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSchools()
        
        schoolTableViewHightConstraint.constant = CGFloat((schools.count + 1)) * Constants.schoolTVCellStandardHeight + 40
    }
    
    // MARK: - @IBAction
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension AddSchoolVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        schools.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SchoolTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        if indexPath.row < schools.count {
            cell.configureCell(model: schools[indexPath.row])
        } else {
            cell.configureAddSchool()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == schools.count {
            guard let vc = homeStoryboard.instantiateViewController(identifier: "GoToSafariVC") as? GoToSafariVC else { return }
            vc.addSchoolVC = self
            self.navigationController?.pushViewController(vc, animated: true)
            print("TODO - Add School")
        } else {
            guard let vc = homeStoryboard.instantiateViewController(identifier: "ConnectCanvasVC") as? ConnectCanvasVC,
            let registrationModel = registrationModel else { return }
            vc.registerModel = registrationModel
            vc.schoolModel = schools[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            print("TODO - Change model")
        }
    }
}

// MARK: - AddSchoolDelegate
extension AddSchoolVC: AddSchoolDelegate {
    func school(model: SchoolModel) {
        schools.append(model)
        schoolTableViewHightConstraint.constant = CGFloat((schools.count + 1)) * Constants.schoolTVCellStandardHeight + 40
        schoolsTableView.reloadData()
    }
}

// MARK: - Network
extension AddSchoolVC {
    private func getSchools() {
        APIManager.getSchools {  [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(schools):
                strongSelf.schools = schools
                strongSelf.schoolTableViewHightConstraint.constant = CGFloat((schools.count + 1)) * Constants.schoolTVCellStandardHeight + 40
                strongSelf.schoolsTableView.reloadData()
            case let .failure(error):
                break
            }
        }
    }
}
