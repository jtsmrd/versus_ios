//
//  CompetitionCommentsVC.swift
//  Versus
//
//  Created by JT Smrdel on 7/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol CompetitionCommentsVCDelegate {
    func dismissComments()
    func expandCommentsView()
    func retractCommentsView()
}

class CompetitionCommentsVC: UIViewController {

    
    @IBOutlet weak var commentsHeaderView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var noCommentsView: UIView!
    @IBOutlet weak var enterCommentView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentPlaceholderLabel: UILabel!
    @IBOutlet weak var postCommentButton: UIButton!
    
    @IBOutlet weak var enterCommentsViewBottom: NSLayoutConstraint!
    
    var delegate: CompetitionCommentsVCDelegate?
    var competitionEntryId: String!
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.layer.cornerRadius = 10
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        commentsHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CompetitionCommentsVC.dismissComments)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CompetitionCommentsVC.keyboardWillShow(notification:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CompetitionCommentsVC.keyboardWillHide(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    func initData(delegate: CompetitionCommentsVCDelegate) {
        self.delegate = delegate
    }
    
    
    @IBAction func postCommentButtonAction() {
        postComment()
    }
    
    
    @objc func dismissComments() {
        delegate?.dismissComments()
        view.endEditing(true)
        self.commentTextView.text.removeAll()
        self.commentPlaceholderLabel.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.height {
            enterCommentsViewBottom.constant = keyboardHeight
            delegate?.expandCommentsView()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        enterCommentsViewBottom.constant = 0
        delegate?.retractCommentsView()
    }
    
    
    private func postComment() {
        
        CommentService.instance.postComment(
            competitionEntryId: competitionEntryId,
            commentText: commentTextView.text
        ) { (success) in
            DispatchQueue.main.async {
                if success {
                    self.view.endEditing(true)
                    self.commentTextView.text.removeAll()
                    self.commentPlaceholderLabel.isHidden = false
                    self.loadCommentsFor(competitionEntryId: self.competitionEntryId)
                }
            }
        }
    }
    
    
    func loadCommentsFor(competitionEntryId: String) {
        
        self.competitionEntryId = competitionEntryId
        
        CommentService.instance.getComments(for: competitionEntryId) { (comments, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else {
                    self.comments = comments.sorted { $0.awsComment._createDate! < $1.awsComment._createDate! }
                    self.commentsTableView.reloadData()
                    
                    if !self.comments.isEmpty {
                        self.commentsTableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            }
        }
    }
}

extension CompetitionCommentsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commentsCount = comments.count
        noCommentsView.isHidden = commentsCount > 0 ? true : false
        tableView.separatorStyle = commentsCount > 0 ? .singleLine : .none
        return commentsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: COMPETITION_COMMENT_CELL, for: indexPath) as? CompetitionCommentCell {
            cell.configureCell(comment: comments[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension CompetitionCommentsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension CompetitionCommentsVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Hide the keyboard when the 'Done' button is tapped
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        // Hide/show the placeholer label text
        if !text.isEmpty {
            commentPlaceholderLabel.isHidden = true
            postCommentButton.isEnabled = true
        }
        else if text == "" && textView.text.count == 1 {
            commentPlaceholderLabel.isHidden = false
            postCommentButton.isEnabled = false
        }
        
        return true
    }
}