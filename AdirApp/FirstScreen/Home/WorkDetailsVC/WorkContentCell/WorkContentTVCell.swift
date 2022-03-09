//
//  WorkContentTVCell.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 25.10.2021.
//

import UIKit

enum SelectedAnswer {
    case a
    case b
    case c
    case d
    case notSelected
}

class WorkContentModel {
    let modelId: String
    let quizId: String?
    var image: UIImage
    var questionType: QuestionType?
    var descriptionText: String
    var base64String: String
    var easyAnswer: String?
    var aButton: AnswerButtonState
    var bButton: AnswerButtonState
    var cButton: AnswerButtonState
    var dButton: AnswerButtonState
    
    init(
        modelId: String,
        quizId: String?,
        image: UIImage,
        questionType: QuestionType?,
        descriptionText: String,
        base64String: String,
        easyAnswer: String?,
        aButton: AnswerButtonState,
        bButton: AnswerButtonState,
        cButton: AnswerButtonState,
        dButton: AnswerButtonState) {
            self.modelId = modelId
            self.quizId = quizId
            self.image = image
            self.questionType = questionType
            self.descriptionText = descriptionText
            self.base64String = base64String
            self.easyAnswer = easyAnswer
            self.aButton = aButton
            self.bButton = bButton
            self.cButton = cButton
            self.dButton = dButton
    }
}

struct AnswerButtonState {
    var title: String?
    var answerId: String?
    var state: SelectedAnswer = .notSelected
}

final class WorkContentTVCell: UITableViewCell {
    
    @IBOutlet private var questionImage: UIImageView!
    @IBOutlet private var questionDescriptionLabel: UILabel!
    
    @IBOutlet weak var answersContainerStackView: UIStackView!
    
    @IBOutlet weak var aContainer: UIView!
    @IBOutlet weak var aCharacterLabel: UILabel!
    @IBOutlet weak var aAnswerLabel: UILabel!
    
    @IBOutlet weak var bContainer: UIView!
    @IBOutlet weak var bCharacterLabel: UILabel!
    @IBOutlet weak var bAnswerLabel: UILabel!
    
    @IBOutlet weak var cContainer: UIView!
    @IBOutlet weak var cCharacterLabel: UILabel!
    @IBOutlet weak var cAnswerLabel: UILabel!
    
    @IBOutlet weak var dContainer: UIView!
    @IBOutlet weak var dCharacterLabel: UILabel!
    @IBOutlet weak var dAnswerLabel: UILabel!
    
    @IBOutlet private var openGalleryButton: UIButton!
    @IBOutlet private var openGalleryButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var easyQuestionTextView: UITextView!
    
    private var delegate: DidSelectAnswerDelegate?
    private var model: WorkContentModel?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        
        self.selectionStyle = .none
        addTapsToAnswers()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        deselectAllAnswers()
    }
    
    // MARK: - Public Methods

    func configureCell(model: WorkContentModel, delegate: DidSelectAnswerDelegate) {
        deselectAllAnswers()
        self.delegate = delegate
        self.model = model
        easyQuestionTextView.delegate = self
        easyQuestionTextView.text = model.easyAnswer
        questionImage.image = nil //model.image
        questionDescriptionLabel.text = model.descriptionText
        answersContainerStackView.distribution = checkAnswersCount(model: model) > 1 ? .fillEqually : .fill
        
        setupAnswerButtonState(container: aContainer, state: model.aButton)
        setupAnswerButtonState(container: bContainer, state: model.bButton)
        setupAnswerButtonState(container: cContainer, state: model.cButton)
        setupAnswerButtonState(container: dContainer, state: model.dButton)
        setupAnswerButtons(questionType: model.questionType)
    }
    
    private func setupAnswerButtonState(container: UIView, state: AnswerButtonState) {
        selectAnswer(answerType: state.state, state: state)
        switch container {
        case aContainer:
            aContainer.isHidden = state.title == nil
            aAnswerLabel.text = state.title
        case bContainer:
            bContainer.isHidden = state.title == nil
            bAnswerLabel.text = state.title
        case cContainer:
            cContainer.isHidden = state.title == nil
            cAnswerLabel.text = state.title
        case dContainer:
            dContainer.isHidden = state.title == nil
            dAnswerLabel.text = state.title
        default:
            break
        }
    }
    
    private func checkAnswersCount(model: WorkContentModel) -> Int {
        var answerCounter: Int = 0
        if model.aButton.title != nil {
            answerCounter += 1
        }
        if model.bButton.title != nil {
            answerCounter += 1
        }
        if model.cButton.title != nil {
            answerCounter += 1
        }
        if model.dButton.title != nil {
            answerCounter += 1
        }
        return answerCounter
    }
    
    private func deselectAllAnswers() {
        aContainer.backgroundColor = .white
        aCharacterLabel.textColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        aAnswerLabel.textColor = .black
        
        bContainer.backgroundColor = .white
        bCharacterLabel.textColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        bAnswerLabel.textColor = .black
        
        cContainer.backgroundColor = .white
        cCharacterLabel.textColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        cAnswerLabel.textColor = .black
        
        dContainer.backgroundColor = .white
        dCharacterLabel.textColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
        dAnswerLabel.textColor = .black
    }
    
    private func setupAnswerButtons(questionType: QuestionType?) {
        self.layoutIfNeeded()
        openGalleryButtonHeightConstraint.constant = answersContainerStackView.frame.height / 4
        openGalleryButton.addBottomShadow()
        openGalleryButtonSetupColor()
        switch questionType {
        case .fileUpload:
            easyQuestionTextView.isHidden = true
            openGalleryButton.isHidden = false
        case .shortAnswer, .essayQuestion:
            easyQuestionTextView.isHidden = false
            openGalleryButton.isHidden = true
        case .trueFalse, .multipleChoice:
            openGalleryButton.isHidden = true
            easyQuestionTextView.isHidden = true
        case .undeclared:
            easyQuestionTextView.isHidden = true
            openGalleryButton.isHidden = true
        default: break
        }
    }
    
    private func openGalleryButtonSetupColor() {
        guard let model = model else { return }
        openGalleryButton.tintColor = model.base64String == "" ? .black : .white
        openGalleryButton.backgroundColor = model.base64String == "" ? .white : .black
    }
    
    private func selectAnswer(answerType: SelectedAnswer, state: AnswerButtonState) {
        if answerType != .notSelected {
            guard let model = model else { return }
            let answerVoteModel = AnswerVoteModel(
                quizId: model.quizId ?? "",
                questionId: model.modelId,
                answer: state.answerId ?? "",
                fileString64: ""
            )
            self.delegate?.didSelectAnswer(modelId: model.modelId, newState: answerType, answerVoteModel: answerVoteModel)
        }
        switch answerType {
        case .a:
            aContainer.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            aCharacterLabel.textColor = .white
            aAnswerLabel.textColor = .white
        case .b:
            bContainer.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            bCharacterLabel.textColor = .white
            bAnswerLabel.textColor = .white
        case .c:
            cContainer.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            cCharacterLabel.textColor = .white
            cAnswerLabel.textColor = .white
        case .d:
            dContainer.backgroundColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            dCharacterLabel.textColor = .white
            dAnswerLabel.textColor = .white
        case .notSelected:
            return
        }
    }
    
    private func addTapsToAnswers() {
        let aTap = UITapGestureRecognizer(target: self, action: #selector(aDidTap))
        aContainer.addGestureRecognizer(aTap)
        aContainer.addBottomShadow()
        
        let bTap = UITapGestureRecognizer(target: self, action: #selector(bDidTap))
        bContainer.addGestureRecognizer(bTap)
        bContainer.addBottomShadow()
        
        let cTap = UITapGestureRecognizer(target: self, action: #selector(cDidTap))
        cContainer.addGestureRecognizer(cTap)
        cContainer.addBottomShadow()
        
        let dTap = UITapGestureRecognizer(target: self, action: #selector(dDidTap))
        dContainer.addGestureRecognizer(dTap)
        dContainer.addBottomShadow()
    }
    
    @objc private func aDidTap() {
        guard let model = model else { return }
        deselectAllAnswers()
        selectAnswer(answerType: .a, state: model.aButton)
    }
    
    @objc private func bDidTap() {
        guard let model = model else { return }
        deselectAllAnswers()
        selectAnswer(answerType: .b, state: model.bButton)
    }
    
    @objc private func cDidTap() {
        guard let model = model else { return }
        deselectAllAnswers()
        selectAnswer(answerType: .c, state: model.cButton)
    }
    
    @objc private func dDidTap() {
        guard let model = model else { return }
        deselectAllAnswers()
        selectAnswer(answerType: .d, state: model.dButton)
    }
    
    @IBAction func openGaleryButtonAction(_ sender: UIButton) {
        guard let model = model else { return }
        delegate?.openGalleryTapped(questionId: model.modelId)
        openGalleryButton.tintColor = .white
        openGalleryButton.backgroundColor = .black
    }
}

extension WorkContentTVCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let model = model else { return }
        let answerVoteModel = AnswerVoteModel(
            quizId: model.quizId ?? "",
            questionId: model.modelId,
            answer: textView.text ?? "",
            fileString64: ""
        )
        self.delegate?.textDidChange(modelId: model.modelId, answerVoteModel: answerVoteModel)
    }
}

extension WorkContentTVCell: NibLoadableView {}
