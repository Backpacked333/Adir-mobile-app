//
//  SubCommentTVCell.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 26.10.2021.
//

import UIKit

class SubCommentModel {
    let id: String = UUID().uuidString
    var image: UIImage
    var name: String
    var likeCount: Int
    var date: String
    var commentText: String
    
    init(image: UIImage, name: String, likeCount: Int, date: String, commentText: String) {
        self.image = image
        self.name = name
        self.likeCount = likeCount
        self.date = date
        self.commentText = commentText
    }
}

final class SubCommentTVCell: UITableViewCell {
    
    @IBOutlet private var avatarImage: UIImageView!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var commentTextLabel: UILabel!
    @IBOutlet private var likeContainerView: UIView!
    @IBOutlet private var likeCountLabel: UILabel!
    
    private var commentId: String?
    private var delegate: DidLikeCommentDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        self.selectionStyle = .none
        
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(increaseLikeCount))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Public Methods

    func configureCell(model: SubCommentModel, delegate: DidLikeCommentDelegate) {
        self.avatarImage.image = model.image
        self.userNameLabel.text = model.name
        self.timeLabel.text = model.date
        self.commentTextLabel.text = model.commentText
        self.likeCountLabel.text = String(model.likeCount)
        self.likeContainerView.isHidden = model.likeCount < 1
        self.delegate = delegate
        self.commentId = model.id
    }
    
    @objc private func increaseLikeCount() {
        let count = (Int(self.likeCountLabel.text ?? "") ?? 0) + 1
        self.likeCountLabel.text = String(count)
        self.likeContainerView.isHidden = count < 1
        self.delegate?.commentLiked(id: self.commentId ?? "")
    }
}

extension SubCommentTVCell: NibLoadableView {}
