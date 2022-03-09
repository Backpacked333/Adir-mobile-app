//
//  SubmitVC.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 25.10.2021.
//

import UIKit

final class SubmitVC: UIViewController {
    
    // MARK: - Public variables
    weak var completeDelegate: AssignmentCompleteDelegate?
    
    var fail = false
    var answerVoteModel: [String: AnswerVoteModel] = [:]
    var quizzeId: String = ""
    
    // MARK: - Private variables
    private var isCompleted: Bool = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - private methods
    private func sendAnswers() {
        var answers: [[String : Any]] = []
        
        for (_, value) in answerVoteModel {
            let file: [String : Any] = [
                "ext" : "png",
                "content" : value.fileString64
            ]
            let answer: [String : Any] = [
                "question_id" : value.questionId,
                "answer" : value.answer == "" ? "000" : value.answer,
                "file" : file
            ]
            answers.append(answer)
        }
        
        let params: [String: Any] = [
            "quiz_id": quizzeId,
            "answers": answers
        ]
        APIManager.quizAnswer(params: params) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .success:
                UserDefaultsService.removeAnswerModel(fromKey: strongSelf.quizzeId)
                strongSelf.completeDelegate?.quizzeComplete(quizzeId: strongSelf.quizzeId)
                strongSelf.navigationController?.popToRootViewController(animated: true)
            case let .failure(error):
                strongSelf.fail = true
                print(error)
            }
        }
    }
    
    // MARK: - @IBActions
    @IBAction private func submitButtonTapped(_ sender: Any) {
        sendAnswers()
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
