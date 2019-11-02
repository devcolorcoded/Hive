//
//  CommentsViewController.swift
//  Hive
//
//  Created by Chuck Onwuzuruike on 10/7/18.
//  Copyright © 2018 Chuck Onwuzuruike. All rights reserved.
//

import Foundation
import UIKit

class CommentsViewController: UIViewController {
    
    let POST_VIEW_CELL_REUSE_IDENTIFIER = "postView"
    let POST_VIEW_CELL_NIB_NAME = "PostView"
    
    @IBOutlet weak var commentFeedView: CommentFeedView!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var commentBn: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    
    private(set) var post: Post? = nil
    
    private let client: ServerClient = ServerClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        setupPostViewTable()
        setupExitGesture()
        setupCommentTv()
        commentFeedView.configure(delegate: self)
        DispatchQueue.main.async {
            self.postTableView.reloadData()
        }
    }
    
    public func controllerInit(post: Post) {
        self.post = post
    }
    
    private func setupCommentTv() {
        commentTextView.layer.cornerRadius = 10.0
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupExitGesture() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(exitViewController))
        gesture.numberOfTouchesRequired = 1
        gesture.direction = .down
        postTableView.addGestureRecognizer(gesture)
    }
    
    private func setupPostViewTable() {
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.isScrollEnabled = true
        postTableView.register(UINib(nibName: POST_VIEW_CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: POST_VIEW_CELL_REUSE_IDENTIFIER)
        postTableView.isScrollEnabled = false
    }

    @objc func exitViewController(recognizer: UISwipeGestureRecognizer) {
        _ = self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func getAllPostComments(queryParams: QueryParams) {
        client.getAllCommentsForPost(postId: (post?.postId)!, queryParams: queryParams, completion: getAllPostCommentsCompletion)
    }
    
    private func getAllPostCommentsCompletion(responseOr: StatusOr<Response>) {
        if (responseOr.hasError()) {
            // Handle likley connection error
            print("Connection Failure: " + responseOr.getErrorMessage())
            return
        }
        let response = responseOr.get()
        if (!response.ok()) {
            // Handle server error
            print("ServerStatusCode: " + String(describing: responseOr.get().serverStatusCode))
            return
        }
        
        let comments = response.comments
        let newMetadata = response.queryMetadata
        commentFeedView.addMoreComments(moreComments: comments, newMetadata: newMetadata)
        DispatchQueue.main.async {
            self.commentFeedView.reload()
        }
        print("Got post comments: ", responseOr.get().comments)
    }
    
    @IBAction func commentBnAction(_ sender: UIButton) {
        if (commentTextView.text.isEmpty) {
            return
        }
        DispatchQueue.main.async {
            self.commentBn.isEnabled = false
            self.commentTextView.isEditable = false
            self.commentTextView.isSelectable = false
            sender.isEnabled = false
        }
        client.insertComment(username: self.getTestUser(), commentText: commentTextView.text, postId: (post?.postId)!, completion: insertCommentCompletion)
    }
    
    private func insertCommentCompletion(response: StatusOr<Response>) {
        var error: Bool = false
        if (response.hasError()) {
            // Handle likley connection error
            print("Connection Failure: " + response.getErrorMessage())
            error = true
        }
        if (response.get().serverStatusCode != ServerStatusCode.OK) {
            // Handle server error
            print("ServerStatusCode: " + String(describing: response.get().serverStatusCode))
            error = true
        }
        commentFeedView.fetchMoreComments(getNewer: true)
        DispatchQueue.main.async {
            self.commentTextView.isEditable = true
            self.commentTextView.isSelectable = true
            if (!error) {
                self.commentTextView.text = ""
            }
            self.commentBn.isEnabled = true
        }
    }
}

// --------------- Extensions ----------------

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostView = tableView.dequeueReusableCell(withIdentifier: POST_VIEW_CELL_REUSE_IDENTIFIER) as! PostView
        cell.configureDisableButtons(post: self.post!)
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.blue.cgColor
        DispatchQueue.main.async {
            cell.commentBn.isEnabled = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension CommentsViewController: CommentFeedViewDelegate {
    func fetchComments(queryParams: QueryParams) {
        self.getAllPostComments(queryParams: queryParams)
    }
}
