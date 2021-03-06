//
//  PostViewTableViewCell.swift
//  Hive
//
//  Created by Chuck Onwuzuruike on 10/7/18.
//  Copyright © 2018 Chuck Onwuzuruike. All rights reserved.
//

import UIKit

protocol PostViewDelegate: class {
    func commentButtonClick(postView: PostView)
    func performAction(postView: PostView, actionType: ActionType)
}

class PostView: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var dislikeBn: UIButton!
    @IBOutlet weak var commentBn: UIButton!
    @IBOutlet weak var likeBn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var netLikesLabel: UILabel!
    
    private var _delegate: PostViewDelegate?
    private var _post: Post? = nil
    
    private let likeColor = UIColor(red:0.00, green:0.51, blue:0.28, alpha:1.0)
    private let dislikeColor = UIColor(red:0.89, green:0.09, blue:0.04, alpha:1.0)
    private let noActionColor = UIColor(red:0.75, green:0.74, blue:0.76, alpha:1.0)
    
    var delegate: PostViewDelegate {
        set { _delegate = newValue }
        get { return _delegate! }
    }

    var post: Post {
        set { _post = newValue }
        get { return _post! }
    }
    
    public func configure(post: Post) {
        userLabel.text = post.username
        postTextView.text = post.postText
        commentBn.titleLabel?.adjustsFontSizeToFitWidth = true
        let netLikes = post.likes - post.dislikes
        netLikesLabel.text = String(netLikes)
        dateLabel.text = post.timeDiffToString()
        self.post = post
        
        likeBn.isEnabled = true;
        dislikeBn.isEnabled = true;
        // Handle like/dislike behavior and other things that need to happen on
        // the dispatch queue.
        DispatchQueue.main.async {
            switch post.userActionType {
            case ActionType.LIKE:
                self.likeBn.tintColor = self.likeColor
                self.dislikeBn.tintColor = self.noActionColor
                self.setNetLikesColor(netLikes: netLikes)
                break;
            case ActionType.DISLIKE:
                self.likeBn.tintColor = self.noActionColor
                self.dislikeBn.tintColor = self.dislikeColor
                self.setNetLikesColor(netLikes: netLikes)
                break;
            case ActionType.NO_ACTION:
                self.likeBn.tintColor = self.noActionColor
                self.dislikeBn.tintColor = self.noActionColor
                self.setNetLikesColor(netLikes: netLikes)
                break;
            }
            let word = UtilityBelt.pluralOrSingular(num: post.numberOfComments, word: " comments")
            self.commentBn.setTitle(String(post.numberOfComments) + word, for:.normal)
        }
    }
    
    public func configure(post: Post, delegate: PostViewDelegate) {
        configure(post: post)
        self.delegate = delegate
    }
    
    public func configureDisable(post: Post) {
        configure(post: post)
        self.isUserInteractionEnabled = false
    }
    
    public func disableLikeAndDislikeButtons() {
        dislikeBn.isEnabled = false
        likeBn.isEnabled = false
    }
    
    @IBAction func dislikeBnAction(_ sender: UIButton) {
        disableLikeAndDislikeButtons()
        switch post.userActionType {
        case ActionType.NO_ACTION, ActionType.LIKE:
            delegate.performAction(postView: self, actionType: ActionType.DISLIKE)
            break;
        case ActionType.DISLIKE:
            delegate.performAction(postView: self, actionType: ActionType.NO_ACTION)
            break;
        }
    }
    @IBAction func likeBnAction(_ sender: UIButton) {
        disableLikeAndDislikeButtons()
        switch post.userActionType {
        case ActionType.NO_ACTION, ActionType.DISLIKE:
            delegate.performAction(postView: self, actionType: ActionType.LIKE)
            break;
        case ActionType.LIKE:
            delegate.performAction(postView: self, actionType: ActionType.NO_ACTION)
            break;
        }
    }
    @IBAction func commentBnAction(_ sender: UIButton) {
        delegate.commentButtonClick(postView: self)
    }
    
    private func setNetLikesColor(netLikes: Int) {
        if netLikes >  0 {
            self.netLikesLabel.textColor = likeColor
        } else if netLikes < 0{
            self.netLikesLabel.textColor = dislikeColor
        } else {
            self.netLikesLabel.textColor = noActionColor
        }
    }
}
