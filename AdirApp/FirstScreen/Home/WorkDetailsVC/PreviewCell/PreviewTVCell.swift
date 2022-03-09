//
//  PreviewTVCell.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 25.10.2021.
//

import UIKit

struct PreViewWorkModel {
    var image: UIImage
    var title: String
    var description: String
    var dateString: String
    var timeString: String
    var points: String
}

final class PreviewTVCell: UITableViewCell {
    
    @IBOutlet private var previewImageView: UIImageView!
    @IBOutlet private var previewTitleLabel: UILabel!
    @IBOutlet private var previewDescriptionLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var summativeLabel: UILabel!
    @IBOutlet private var swipeToStartLabel: UILabel!
    
    @IBOutlet private var previewTitleTopConstraint: NSLayoutConstraint! // 37
    @IBOutlet private var previewTitleBottomConstraint: NSLayoutConstraint! //34
    @IBOutlet private var previewDescriptionTopConstraint: NSLayoutConstraint! // 55
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        self.selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Public Methods

    func configureCell(model: AssignmentModel) {
        setupFontSizes()
        setupSpaceSizes()
        self.previewImageView.image = nil //model.image
        self.previewTitleLabel.text = model.name
        self.previewDescriptionLabel.text = model.description
        if let dateString = model.dueAt, let date = DateConverter.getDate(from: dateString, dateFormat: DateFormat.yyyyMMddTHHmmss.rawValue) {
            self.dateLabel.text = DateConverter.getString(from: date, dateFormat: DateFormat.MMMMd.rawValue)
            self.timeLabel.text = DateConverter.getString(from: date, dateFormat: DateFormat.HHmm.rawValue)
        } else {
            self.dateLabel.text = "fail to provide"
            self.timeLabel.text = ""
        }
        guard let points = model.pointsPossible, let double = Double(points) else {
            self.pointsLabel.text = "fail to provide"
            return
        }
        self.pointsLabel.text = "\(Int(double))" + "pts"
    }
    
    private func setupFontSizes() {
        if UIScreen.main.bounds.height <= 736 {
            previewTitleLabel.font = UIFont(name: Fonts.poppinsSemiBold.rawValue, size: 24)
            previewDescriptionLabel.font = UIFont(name: Fonts.poppinsRegular.rawValue, size: 10)
            dateLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 18)
            timeLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 14)
            pointsLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 18)
            summativeLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 14)
        } else {
            previewTitleLabel.font = UIFont(name: Fonts.poppinsSemiBold.rawValue, size: 30)
            previewDescriptionLabel.font = UIFont(name: Fonts.poppinsRegular.rawValue, size: 16)
            dateLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 22)
            timeLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 20)
            pointsLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 22)
            summativeLabel.font = UIFont(name: Fonts.poppinsMedium.rawValue, size: 20)
        }
    }
    
    private func setupSpaceSizes() {
        if UIScreen.main.bounds.height <= 736 {
            previewTitleTopConstraint.constant = 18
            previewTitleBottomConstraint.constant = 17
            previewDescriptionTopConstraint.constant = 25
        } else {
            previewTitleTopConstraint.constant = 37
            previewTitleBottomConstraint.constant = 34
            previewDescriptionTopConstraint.constant = 55
        }
    }
    
    @IBAction func availableNowButtonTapped(_ sender: Any) {
        print("tap")
    }
}

extension PreviewTVCell: NibLoadableView {}
