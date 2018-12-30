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
}

class PostView: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var dislikeBn: UIButton!
    @IBOutlet weak var commentBn: UIButton!
    @IBOutlet weak var likeBn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: PostViewDelegate?
    
    var post: Post? = nil
    
    public func configure(post: Post) {
        userLabel.text = post.username
        postTextView.text = post.postText
        dislikeBn.setTitle("Dislike: " + String(post.dislikes), for: UIControlState.normal)
        likeBn.setTitle("Like: " + String(post.likes), for: UIControlState.normal)
        dateLabel.text = self.timestampToDate(timestampSec: post.creationTimestampSec)
        self.post = post
    }
    
    @IBAction func commentBnAction(_ sender: UIButton) {
        delegate?.commentButtonClick(postView: self)
    }
}
