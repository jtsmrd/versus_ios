//
//  CommentsVC.swift
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

class CommentsVC: UIViewController {

    
    @IBOutlet weak var commentsHeaderView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var noCommentsView: UIView!
    @IBOutlet weak var enterCommentView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentPlaceholderLabel: UILabel!
    @IBOutlet weak var postCommentButton: UIButton!
    
    @IBOutlet weak var enterCommentsViewBottom: NSLayoutConstraint!
    
    let commentService = CommentService.instance
    
    var delegate: CompetitionCommentsVCDelegate?
    var competitionEntryId: String!
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.layer.cornerRadius = 10
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        commentsHeaderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CommentsVC.dismissComments)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CommentsVC.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CommentsVC.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    func initData(delegate: CompetitionCommentsVCDelegate) {
        self.delegate = delegate
    }
    
    
    @IBAction func postCommentButtonAction() {
        
        let commentText: String = commentTextView.text
        
        postComment(
            competitionEntryId: competitionEntryId,
            commentText: commentText,
            userId: CurrentUser.userId,
            username: CurrentUser.username
        )
    }
    
    
    @objc func dismissComments() {
        delegate?.dismissComments()
        view.endEditing(true)
        self.commentTextView.text.removeAll()
        self.commentPlaceholderLabel.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height {
            enterCommentsViewBottom.constant = keyboardHeight
            delegate?.expandCommentsView()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        enterCommentsViewBottom.constant = 0
        delegate?.retractCommentsView()
    }
    
    
    private func postComment(
        competitionEntryId: String,
        commentText: String,
        userId: String,
        username: String
    ) {
        
        commentService.postComment(
            competitionEntryId: competitionEntryId,
            commentText: commentText,
            userId: userId,
            username: username
        ) { (customError) in
            
            DispatchQueue.main.async {
                
                if let customError = customError {
                    self.displayError(error: customError)
                    return
                }
                
                self.view.endEditing(true)
                self.commentTextView.text.removeAll()
                self.commentPlaceholderLabel.isHidden = false
                self.loadCommentsFor(competitionEntryId: self.competitionEntryId)
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
                    self.comments = comments.sorted { $0.createDate < $1.createDate }
                    self.commentsTableView.reloadData()
                    
                    if !self.comments.isEmpty {
                        self.commentsTableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            }
        }
    }
}

extension CommentsVC: UITableViewDataSource {
    
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

extension CommentsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension CommentsVC: UITextViewDelegate {
    
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
