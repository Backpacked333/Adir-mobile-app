//
//  WorkDetailsVC.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 22.10.2021.
//

import UIKit
import MobileCoreServices

protocol DidLikeCommentDelegate {
    func commentLiked(id: String)
}

class MostSelectedModel {
    let id: String = UUID().uuidString
    var selectedChar: String
    var selectedAnswer: String
    var comments: [CommentModel] = []
    
    init(selectedChar: String, selectedAnswer: String, comments: [CommentModel]) {
        self.selectedChar = selectedChar
        self.selectedAnswer = selectedAnswer
        self.comments = comments
    }
}

protocol DidSelectAnswerDelegate {
    func didSelectAnswer(modelId: String, newState: SelectedAnswer, answerVoteModel: AnswerVoteModel)
    func openGalleryTapped(questionId: String)
    func textDidChange(modelId: String, answerVoteModel: AnswerVoteModel)
}

final class WorkDetailsVC: BaseVC {
    
    @IBOutlet private var mainScrollView: UIScrollView!
    @IBOutlet private var progressView: UIView!
    @IBOutlet private var questionsTableView: UITableView! {
        didSet {
            questionsTableView.register(PreviewTVCell.self)
            questionsTableView.register(WorkContentTVCell.self)
            questionsTableView.delegate = self
            questionsTableView.dataSource = self
            questionsTableView.rowHeight = questionsTableView.frame.height
            questionsTableView.allowsSelection = false
            questionsTableView.tableFooterView = UIView()
        }
    }
    @IBOutlet private var emptyLabel: UILabel!
    @IBOutlet private var progressGradientView: UIView!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressLeadingConstraint: NSLayoutConstraint! // 30 for start
    @IBOutlet private var mostSelectedCharacterLabel: UILabel!
    @IBOutlet private var mostSelectedAnswerLabel: UILabel!
    @IBOutlet private var commentsTableView: UITableView! {
        didSet {
            commentsTableView.register(CommentTVCell.self)
            commentsTableView.delegate = self
            commentsTableView.dataSource = self
            commentsTableView.rowHeight = UITableView.automaticDimension
//            commentsTableView.estimatedRowHeight = 100
            commentsTableView.allowsSelection = false
            commentsTableView.tableFooterView = UIView()
        }
    }
    @IBOutlet private var commentTextField: UITextField!
    @IBOutlet private var commentTextFieldBottomSpace: NSLayoutConstraint!
    
    @IBOutlet private var blockerView: UIView!
    @IBOutlet private var blockerActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var commentBlockerView: UIView!
    @IBOutlet private var commentBlockerActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public variables
    var workModel: AssignmentModel?
    weak var completeDelegate: AssignmentCompleteDelegate?
    
    // MARK: - Private enum
    
    private enum PickerType {
        case forComment
        case forQuestions
        case none
    }
    
    // MARK: - Private variables
    private var lastXOffset: CGFloat = 0
    private var pickerType: PickerType = .none
    private var questionId: String = ""
    private var isFirstRequest: Bool = true
    private var totalQuestions: Int = 0
    private var questionModels: [WorkContentModel] = []
    private var answerVoteModels: [String: AnswerVoteModel] = [:]
    private var savedAnswers: [String: [String: AnswerVoteModel]] = [:]
    private var loadCount = 0
    private var isOpenSubmit = false
    private let gradientLayer = CAGradientLayer()
    private var commentModels: [GetCommentModel] = [] {
        didSet{
            emptyLabel.isHidden = commentModels.count > 0
        }
    }
    private var mostSelectedModel = MostSelectedModel(selectedChar: "A.",
                                                      selectedAnswer: "Deforistation for lumber and natural resources", comments: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSavedAnswers()
        
        setupMostSelectedState()
        setupView()
        addMoveToBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstRequest {
            loadQuestions()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard loadCount < 1 else { return }
        loadCount += 1
        reloadWidth()
    }
    
    override func keyboardWillShow(notification notif: NSNotification) {
        let height = getKeyboardHeight(notif)
        commentTextFieldBottomSpace.constant = height
    }
    
    override func keyboardWillHide(notification _: NSNotification) {
        commentsTableView.contentInset = .zero
        commentTextFieldBottomSpace.constant = 3
    }
    
    private func setSavedAnswers() {
        guard let answers = UserDefaultsService.getAnswerModel(),
              let quizId = workModel?.quizID,
              let model = answers[quizId] else { return }
        savedAnswers = answers
        answerVoteModels = model
    }
    
    private func setupView() {
        hideKeyboardWhenTappedAround()
        mainScrollView.isScrollEnabled = false
        mainScrollView.delegate = self
        commentTextField.delegate = self
    }
    
    private func setupMostSelectedState() {
        commentsTableView.reloadData()
        mostSelectedAnswerLabel.text = mostSelectedModel.selectedAnswer
        mostSelectedCharacterLabel.text = mostSelectedModel.selectedChar
    }
    
    private func reloadWidth() {
        self.view.layoutIfNeeded()
        self.questionsTableView.reloadData()
        createProgressAnimation()
        DispatchQueue.main.async {
            self.setGradientBackground()
        }
    }
    
    func setGradientBackground() {
        gradientLayer.removeFromSuperlayer()
        let color1 = #colorLiteral(red: 0, green: 0.7137254902, blue: 0.4156862745, alpha: 1)
        let color2 = #colorLiteral(red: 0, green: 0.7137254902, blue: 0.4156862745, alpha: 0.7)
        let color3 = #colorLiteral(red: 0, green: 0.7137254902, blue: 0.4156862745, alpha: 0.82)
        let color4 = #colorLiteral(red: 0, green: 0.7137254902, blue: 0.4156862745, alpha: 0.7)
                    
        gradientLayer.colors = [color1.cgColor, color2.cgColor, color3.cgColor, color4.cgColor]
        
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = self.progressGradientView.bounds
                
        self.progressGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func createProgressAnimation() {
        let totalCount = CGFloat(totalQuestions) + 1
        let additionalStep: CGFloat = (questionsTableView.contentOffset.y/questionsTableView.frame.height) > 0 ? 1 : 0
        let steppedCount: CGFloat = (questionsTableView.contentOffset.y/questionsTableView.frame.height) + additionalStep
        let percent = steppedCount/totalCount
        let spaceForAnimation = progressView.frame.width - 30
        progressLeadingConstraint.constant = 30 + (spaceForAnimation*percent)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        UIView.performWithoutAnimation {
            self.progressLabel.text = "\(Int(percent*100))%"
        }
    }
    
    private func openGallery(pickerType: PickerType) {
        self.pickerType = pickerType
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        self.present(picker, animated: true)
    }
    
    private func addSubComment(text: String, commentId: String) {
        let subComment = SubCommentModel(image: #imageLiteral(resourceName: "testQuestionIcon"),
                                         name: "Roy Salman",
                                         likeCount: 0,
                                         date: "2 sec",
                                         commentText: text)
        for index in 0 ..< mostSelectedModel.comments.count {
            if mostSelectedModel.comments[index].id == commentId {
                mostSelectedModel.comments[index].subComments.append(subComment)
                commentsTableView.beginUpdates()
                commentsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                commentsTableView.endUpdates()
                commentTextField.text = ""
                return
            }
        }
    }
    
    private func startLoading(blockerView: UIView, blockerActivityIndicator: UIActivityIndicatorView) {
        blockerView.isHidden = false
        blockerActivityIndicator.startAnimating()
    }
    
    private func stopLoading(blockerView: UIView, blockerActivityIndicator: UIActivityIndicatorView) {
        blockerView.isHidden = true
        blockerActivityIndicator.stopAnimating()
    }
    
    private func getSavedBase64(questionId: String) -> String {
        guard let quizId = workModel?.quizID else { return "" }
        let model = savedAnswers[quizId]
        guard let base64String = model?[questionId] else { return "" }
        return base64String.fileString64
    }
    
    private func getSavedEasyAnswer(questionId: String) -> String {
        guard let quizId = workModel?.quizID else { return "" }
        let model = savedAnswers[quizId]
        guard let easyAnswer = model?[questionId] else { return "" }
        return easyAnswer.answer
    }
    
    private func getButtonsState(answerDictionary: [String: String], questionId: String) -> [AnswerButtonModel] {
        var answerButtonModel: [AnswerButtonModel] = []
        var quiz: [String: AnswerVoteModel] = [:]
        if let quizId = workModel?.quizID {
            if let savedQuiz = savedAnswers[quizId] {
                quiz = savedQuiz
            }
        }
        
        var answers: String = ""
        var answerID: String = ""
        var answerState: Bool = false
        
        for (key, value) in answerDictionary {
            answerID = key
            answers = value
            if let answerModel = quiz[questionId] {
                if key == answerModel.answer {
                    answerState = true
                } else {
                    answerState = false
                }
            }
            answerButtonModel.append(AnswerButtonModel(answer: answers, answerId: answerID, answerState: answerState))
        }
        
        return answerButtonModel
    }
    
    private func saveAnsweredQuestions() {
        guard let quizId = workModel?.quizID else { return }
        var answerVoteModel: [String: AnswerVoteModel] = [:]
        for (_, value) in answerVoteModels {
            let answerModel = AnswerVoteModel(quizId: value.quizId, questionId: value.questionId, answer: value.answer, fileString64: value.fileString64)
            answerVoteModel[value.questionId] = answerModel
        }
        savedAnswers[quizId] = answerVoteModel
        UserDefaultsService.saveAnswerModel(model: savedAnswers)
    }
    
    private func clearTemporaryData() {
        pickerType = .none
        questionId = ""
    }
    
    private func addMoveToBackground() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func getScrollDirection(scrollView: UIScrollView) {
        guard let index = questionsTableView.indexPathsForVisibleRows?.first else { return }
        if scrollView == mainScrollView {
            if self.lastXOffset > scrollView.contentOffset.x {
                cleanCommentModels()
//                adirHellpButton(hide: false)
            } else if self.lastXOffset < scrollView.contentOffset.x {
                loadComments()
//                adirHellpButton(hide: true)
            }
            self.lastXOffset = scrollView.contentOffset.x
        } else if scrollView == questionsTableView {
            if index.section == 0 {
//                adirHellpButton(hide: true)
            } else {
                self.view.endEditing(true)
//                adirHellpButton(hide: false)
            }
        }
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Do you really want to leave this page?", message: "", preferredStyle: UIAlertController.Style.alert)
        let leaveAction = UIAlertAction(title: "Leave", style: UIAlertAction.Style.default, handler: { alert -> Void in
            self.saveAnsweredQuestions()
            self.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(leaveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    
    @IBAction private func addCommentButtonTapped(_ sender: Any) {
        guard let text = commentTextField.text, text.count > 0 else { return }
        upload(comment: text)
    }
    
    // MARK: - @objc Method
    
    @objc func appMovedToBackground() {
        self.saveAnsweredQuestions()
    }
}

extension WorkDetailsVC: DidLikeCommentDelegate {
    func commentLiked(id: String) {
        for comment in mostSelectedModel.comments {
            if comment.id == id {
                comment.likeCount += 1
            }
            for subComment in comment.subComments {
                if subComment.id == id {
                    subComment.likeCount += 1
                }
            }
        }
        commentsTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WorkDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == questionsTableView {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == questionsTableView {
            switch section {
            case 0:
                return 1
            case 1:
                return questionModels.count
            default:
                return 0
            }
        } else {
            return mostSelectedModel.comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == questionsTableView {
            switch indexPath.section {
            case 0:
                let cell: PreviewTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                guard let model = workModel else { return cell }
                cell.configureCell(model: model)
                return cell
            case 1:
                let cell: WorkContentTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.configureCell(model: questionModels[indexPath.row], delegate: self)
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            let cell: CommentTVCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.configureCell(model: mostSelectedModel.comments[indexPath.row], delegate: self, longPressDelegate: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == questionsTableView {
            return questionsTableView.frame.height
        } else {
            return UITableView().estimatedRowHeight
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainScrollView.isScrollEnabled = questionsTableView.contentOffset.y > 100
        
        if scrollView == mainScrollView {
            commentTextField.endEditing(true)
        }
        
        guard scrollView == questionsTableView else { return }
        let minus = scrollView.contentOffset.y - scrollView.contentSize.height
        if minus + scrollView.frame.height > 50, !isOpenSubmit {
            isOpenSubmit = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.isOpenSubmit = false
            })
            let vc = homeStoryboard.instantiateViewController(identifier: "SubmitVC") as! SubmitVC
            vc.quizzeId = workModel?.quizID ?? ""
            vc.answerVoteModel = self.answerVoteModels
            vc.completeDelegate = self.completeDelegate
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == questionsTableView else { return }
        if (scrollView.contentOffset.y - scrollView.contentSize.height) <= UIScreen.main.bounds.height {
            print("scroll view will load questions")
            loadQuestions()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        createProgressAnimation()
        getScrollDirection(scrollView: scrollView)
    }
}

// MARK: - DidSelectAnswerDelegate
extension WorkDetailsVC: DidSelectAnswerDelegate {
    func didSelectAnswer(modelId: String, newState: SelectedAnswer, answerVoteModel: AnswerVoteModel) {
        for model in questionModels {
            if model.modelId == modelId {
                self.answerVoteModels[modelId] = answerVoteModel
                model.aButton.state = .notSelected
                model.bButton.state = .notSelected
                model.cButton.state = .notSelected
                model.dButton.state = .notSelected
                switch newState {
                case .a:
                    model.aButton.state = .a
                case .b:
                    model.bButton.state = .b
                case .c:
                    model.cButton.state = .c
                case .d:
                    model.dButton.state = .d
                case .notSelected:
                    break
                }
                break
            }
        }
    }
    
    func openGalleryTapped(questionId: String) {
        self.questionId = questionId
        openGallery(pickerType: .forQuestions)
    }
    
    func textDidChange(modelId: String, answerVoteModel: AnswerVoteModel) {
        for model in questionModels {
            if model.modelId == modelId {
                model.easyAnswer = answerVoteModel.answer
            }
        }
        self.answerVoteModels[modelId] = answerVoteModel
    }
}

// MARK: - UITextFieldDelegate
extension WorkDetailsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        return true
    }
}

// MARK: - LongPressDelegate
extension WorkDetailsVC: LongPressDelegate {
    func longPress(commentId: String) {
        let alertController = UIAlertController(title: "Add new comment", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter comment"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            guard let text = firstTextField.text, text.count > 0 else { return }
            self.addSubComment(text: text, commentId: commentId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension WorkDetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        switch pickerType {
        case .forQuestions:
            if let base64String = image.pngData()?.base64EncodedString() {
                guard let quizId = workModel?.quizID else { return }
                let answerVoteModel = AnswerVoteModel(
                    quizId: quizId,
                    questionId: questionId,
                    answer: "",
                    fileString64: base64String
                )
                self.answerVoteModels[questionId] = answerVoteModel
                guard let indexPath = questionsTableView.indexPathsForVisibleRows?.first else { return }
                questionModels[indexPath.row].base64String = base64String
                questionsTableView.reloadRows(at: [indexPath], with: .none)
            }
        case .forComment:
            break
//        chosenImage = image
        default: break
        }
        clearTemporaryData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        clearTemporaryData()
        guard let indexPath = questionsTableView.indexPathsForVisibleRows?.first else { return }
        questionsTableView.reloadRows(at: [indexPath], with: .none)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Gestures
extension WorkDetailsVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Work with Questions

extension WorkDetailsVC {
    private func loadQuestions() {
        guard let id = workModel?.quizID else { return }
        startLoading(blockerView: blockerView, blockerActivityIndicator: blockerActivityIndicator)
        
        APIManager.getQuestion(
            id: id,
            skip: questionModels.count,
            limit: questionModels.count + paginationLimit
        ) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case let .success(questionModel):
                var question: QuestionModel = questionModel
                for index in 0 ..< questionModel.questions.count {
                    question.questions[index].dictionaryAnswers = APIManager.getJSON(from: questionModel.questions[index].answers)
                }
                strongSelf.totalQuestions = questionModel.total
                if strongSelf.isFirstRequest {
                    strongSelf.isFirstRequest = false
                        //strongSelf.totalQuestions = 5
                    strongSelf.reloadWidth()
                }
                strongSelf.getWorkModels(from: question)
                strongSelf.stopLoading(blockerView: strongSelf.blockerView, blockerActivityIndicator: strongSelf.blockerActivityIndicator)
            case let .failure(error):
                strongSelf.stopLoading(blockerView: strongSelf.blockerView, blockerActivityIndicator: strongSelf.blockerActivityIndicator)
                print(error)
            }
        }
    }
    
    private func getWorkModels(from question: QuestionModel) {
        for question in question.questions {
            
            var answerModel: [AnswerButtonModel] = []
            
            if let answersDictionary = question.dictionaryAnswers {
                answerModel = getButtonsState(answerDictionary: answersDictionary, questionId: question.id)
            }
            let questionType: QuestionType? = QuestionType(rawValue: question.type ?? "")
            questionModels.append(
                WorkContentModel(
                    modelId: question.id,
                    quizId: question.quizId,
                    image: #imageLiteral(resourceName: "testQuestionIcon"),
                    questionType: questionType,
                    descriptionText: question.text ?? "",
                    base64String: getSavedBase64(questionId: question.id),
                    easyAnswer: getSavedEasyAnswer(questionId: question.id),
                    aButton: AnswerButtonState(
                        title: answerModel.indices.contains(0) ? answerModel[0].answer : nil,
                        answerId: answerModel.indices.contains(0) ? answerModel[0].answerId : nil,
                        state: answerModel.indices.contains(0) ? answerModel[0].answerState ? .a : .notSelected : .notSelected
                    ),
                    bButton: AnswerButtonState(
                        title: answerModel.indices.contains(1) ? answerModel[1].answer : nil,
                        answerId: answerModel.indices.contains(1) ? answerModel[1].answerId : nil,
                        state: answerModel.indices.contains(1) ? answerModel[1].answerState ? .b : .notSelected : .notSelected
                    ),
                    cButton: AnswerButtonState(
                        title: answerModel.indices.contains(2) ? answerModel[2].answer : nil,
                        answerId: answerModel.indices.contains(2) ? answerModel[2].answerId : nil,
                        state: answerModel.indices.contains(2) ? answerModel[2].answerState ? .c : .notSelected : .notSelected
                    ),
                    dButton: AnswerButtonState(
                        title: answerModel.indices.contains(3) ? answerModel[3].answer : nil,
                        answerId: answerModel.indices.contains(3) ? answerModel[3].answerId : nil,
                        state: answerModel.indices.contains(3) ? answerModel[3].answerState ? .d : .notSelected : .notSelected
                    )
                ))
            self.questionsTableView.beginUpdates()
            self.questionsTableView.insertRows(
                at: [IndexPath(
                    row: questionModels.count - 1,
                    section: 1
                )],
                with: .none)
            self.questionsTableView.endUpdates()
        }
    }
}

// MARK: - Work with comments

extension WorkDetailsVC {
    private func upload(comment: String) {
        guard let indexPath = questionsTableView.indexPathsForVisibleRows?.first else { return }
        
        APIManager.addComment(questionIntDb: questionModels[indexPath.row].modelId, content: comment) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                guard let text = strongSelf.commentTextField.text,
                      text.count > 0,
                      let image = UIImage(named: "UserPlaceholder") else { return }
                let commentModel = CommentModel(image: image,
                                                name: "User",
                                                likeCount: 0,
                                                date: "",
                                                commentText: text,
                                                subComments: [])
                strongSelf.mostSelectedModel.comments.append(commentModel)
                strongSelf.commentTextField.text = ""
                strongSelf.commentsTableView.reloadData()
                strongSelf.commentsTableView.layoutIfNeeded()
                strongSelf.commentsTableView.scrollToRow(at: IndexPath(row: strongSelf.mostSelectedModel.comments.count - 1, section: 0), at: .bottom, animated: true)
            case let .failure(error):
                let alert = UIAlertController(title: Alert.error.rawValue, message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: Alert.ok.rawValue, style: UIAlertAction.Style.default, handler: nil))
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func loadComments() {
        guard let indexPath = questionsTableView.indexPathsForVisibleRows?.first else { return }
        startLoading(blockerView: commentBlockerView, blockerActivityIndicator: commentBlockerActivityIndicator)
        APIManager.getComments(
            questionIntDb: questionModels[indexPath.row].modelId
        ) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case let .success(commentModels):
                strongSelf.stopLoading(blockerView: strongSelf.commentBlockerView, blockerActivityIndicator: strongSelf.commentBlockerActivityIndicator)
                strongSelf.getCommentsModel(from: commentModels)
            case let .failure(error):
                strongSelf.stopLoading(blockerView: strongSelf.commentBlockerView, blockerActivityIndicator: strongSelf.commentBlockerActivityIndicator)
                strongSelf.cleanCommentModels()
                print(error)
            }
        }
    }
    
    private func getCommentsModel(from comments: [GetCommentModel]) {
        guard let image = UIImage(named: "UserPlaceholder") else { return }
        for comment in comments {
            commentModels = comments
            mostSelectedModel.comments.append(
                CommentModel(
                    image: image,
                    name: "User",
                    likeCount: 0,
                    date: "",
                    commentText: comment.content,
                    subComments: []
                )
            )
            self.commentsTableView.reloadData()
        }
    }
    
    private func cleanCommentModels() {
        commentModels = []
        mostSelectedModel.comments = []
        commentsTableView.reloadData()
    }
}
