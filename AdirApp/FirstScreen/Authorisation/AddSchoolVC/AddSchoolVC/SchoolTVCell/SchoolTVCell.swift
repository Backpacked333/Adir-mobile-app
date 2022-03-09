//
//  SchoolTVCell.swift
//  AdirApp
//
//  Created by iMac1 on 09.02.2022.
//

import UIKit

final class SchoolTVCell: UITableViewCell {
    
    @IBOutlet weak var imageBorderView: UIView!
    @IBOutlet weak var schoolImage: UIImageView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard let image = UIImage(named: "SchoolPlaceholder") else { return }
        schoolImage.image = image
        self.schoolNameLabel.text = ""
    }
    
    func configureCell(model: SchoolModel) {
        guard let url = URL(string: model.logoURL) else {
            imageBorderView.isHidden = true
            return
        }
        schoolImage.loadImage(from: url)
        schoolNameLabel.text = model.name
    }
    
    func configureAddSchool() {
        guard let image = UIImage(named: "AddSchool") else { return }
        schoolImage.image = image
        schoolNameLabel.text = "Add your school"
    }
}

extension SchoolTVCell: NibLoadableView {}
