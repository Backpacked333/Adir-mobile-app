//
//  WorkTVCell.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 21.10.2021.
//

import UIKit

struct TestWorkModel {
    var image: UIImage
    var title: String
    var dueDate: String
    var isTomorrow: Bool
}


final class WorkTVCell: UITableViewCell {
    @IBOutlet private var workImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var tomorrowLabel: UILabel!
    @IBOutlet private var atLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        self.selectionStyle = .none
        containerView.addBottomShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    

    // MARK: - Public Methods

    func configureCell(model: AssignmentModel) {
        workImageView.image = nil
        titleLabel.text = model.name ?? ""
        if let dateString = model.dueAt, let date = DateConverter.getDate(from: dateString, dateFormat: DateFormat.yyyyMMddTHHmmss.rawValue) {
            var time: String = ""
            if let locked = model.locked, locked == "True" {
                self.subtitleLabel.textColor = .red
                time = "Expired " + DateConverter.getString(from: date, dateFormat: DateFormat.MMMMd.rawValue)
                time += " " + DateConverter.getString(from: date, dateFormat: DateFormat.HHmm.rawValue)
            } else if DateConverter.isDateInToday(date: date) {
                self.subtitleLabel.textColor = .black
                time = DateConverter.getString(from: date, dateFormat: DateFormat.HHmm.rawValue)
            } else {
                self.subtitleLabel.textColor = .black
                time = DateConverter.getString(from: date, dateFormat: DateFormat.MMMMd.rawValue)
                time += " " + DateConverter.getString(from: date, dateFormat: DateFormat.HHmm.rawValue)
            }
            
            self.subtitleLabel.text = time
            tomorrowLabel.isHidden = !DateConverter.isDateInTomorrow(date: date)
            atLabel.isHidden = !DateConverter.isDateInTomorrow(date: date)
        } else {
            tomorrowLabel.isHidden = true
            atLabel.isHidden = true
            self.subtitleLabel.text = "fail to provide"
        }
//        tomorrowLabel.text = model.isTomorrow ? " tomorrow" : ""
//        atLabel.text = model.isTomorrow ? " at " : " "
    }
}

extension WorkTVCell: NibLoadableView {}
