//
//  CommentTVCell.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 26.10.2021.
//

import UIKit

protocol LongPressDelegate {
    func longPress(commentId: String)
}

class CommentModel {
    let id: String = UUID().uuidString
    var image: UIImage
    var name: String
    var likeCount: Int
    var date: String
    var commentText: String
    var subComments: [SubCommentModel]
    
    init(image: UIImage, name: String, likeCount: Int, date: String, commentText: String, subComments: [SubCommentModel]) {
        self.image = image
        self.name = name
        self.likeCount = likeCount
        self.date = date
        self.commentText = commentText
        self.subComments = subComments
    }
}

final class CommentTVCell: UITableViewCell {
    
    @IBOutlet private var avatarImage: UIImageView!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var commentLabel: UILabel!
    @IBOutlet private var likeContainer: UIView!
    @IBOutlet private var likeCountLabel: UILabel!
    @IBOutlet private var subCommentsContainer: UIView!
    @IBOutlet private var subCommentsTableView: UITableView! {
        didSet {
            subCommentsTableView.register(SubCommentTVCell.self)
            subCommentsTableView.delegate = self
            subCommentsTableView.dataSource = self
            subCommentsTableView.rowHeight = UITableView.automaticDimension
//            subCommentsTableView.estimatedRowHeight = 40
            subCommentsTableView.allowsSelection = false
            subCommentsTableView.tableFooterView = UIView()
        }
    }
    @IBOutlet private var subCommentsHeight: NSLayoutConstraint!
    
    private var subComments: [SubCommentModel] = [] {
        didSet {
            subCommentsContainer.isHidden = subComments.count < 1
            subCommentsTableView.reloadData()
            self.layoutIfNeeded()
            self.subCommentsHeight.constant = subCommentsTableView.contentSize.height
        }
    }
    private var commentId: String?
    private var delegate: DidLikeCommentDelegate?
    private var longPressDelegate: LongPressDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        self.selectionStyle = .none
        
        self.addBottomShadow()
        doubleTapGesture()
//        longPressGesture()
        #warning("Long press")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    // MARK: - Public Methods

    func configureCell(model: CommentModel, delegate: DidLikeCommentDelegate, longPressDelegate: LongPressDelegate) {
        self.avatarImage.image = model.image
        self.userNameLabel.text = model.name
        self.timeLabel.text = model.date
        self.commentLabel.text = model.commentText
        self.likeCountLabel.text = String(model.likeCount)
        self.likeContainer.isHidden = model.likeCount < 1
        self.subComments = model.subComments
        self.delegate = delegate
        self.longPressDelegate = longPressDelegate
        self.commentId = model.id
    }
}

extension CommentTVCell: NibLoadableView {}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CommentTVCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SubCommentTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configureCell(model: subComments[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView().estimatedRowHeight
    }
}

extension CommentTVCell: DidLikeCommentDelegate {
    func commentLiked(id: String) {
        self.delegate?.commentLiked(id: id)
    }
}

// MARK: - Gestures
extension CommentTVCell {
    private func longPressGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.contentView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func doubleTapGesture() {
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(increaseLikeCount))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTap)
    }
    
    @objc private func increaseLikeCount() {
        let count = (Int(self.likeCountLabel.text ?? "") ?? 0) + 1
        self.likeCountLabel.text = String(count)
        self.likeContainer.isHidden = count < 1
        self.delegate?.commentLiked(id: self.commentId ?? "")
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            guard let commentId = commentId else { return }
            longPressDelegate?.longPress(commentId: commentId)
        }
    }
}
