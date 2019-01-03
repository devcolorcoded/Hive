//
//  ViewController.swift
//  Hive
//
//  Created by Chuck Onwuzuruike on 10/3/18.
//  Copyright © 2018 Chuck Onwuzuruike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var postTv: UITextView!
    @IBOutlet weak var postBn: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    
    private(set) var client: ServerClient = ServerClient()
    private(set) var fetchPostsMetadata: QueryMetadata = QueryMetadata()
    public private(set) var allPostsAroundUser: Array<Post> = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()
        setupPostTv()
        setupPostBn()
        setupPostTableView()
        fetchPostsAroundUser(getNewPosts: true)
        setupGestureToPopularView()
    }
    
    private func setupGestureToPopularView() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureToPopularViewAction))
        gesture.numberOfTouchesRequired = 1
        gesture.direction = .left
        postTableView.addGestureRecognizer(gesture)
    }
    
    private func setupPostBn() {
        postBn.layer.cornerRadius = 10
        postBn.layer.borderWidth = 1
        postBn.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupPostTv() {
        // Take care of border
        postTv.layer.cornerRadius = 10.0
        postTv.layer.borderWidth = 1.0
        postTv.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupPostTableView() {
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.isScrollEnabled = true
        // Register nib as cell.
        postTableView.register(UINib(nibName: "PostView", bundle: nil), forCellReuseIdentifier: "postViewCell")
        
        // Take care of refreshing
        postTableView.refreshControl = UIRefreshControl()
        postTableView.refreshControl!.addTarget(self, action: #selector(refreshPostTableView(_:)), for: .valueChanged)
    }
    
    @objc func refreshPostTableView(_ refreshControl: UIRefreshControl) {
        // This fetch should also end the refresh.
        fetchPostsAroundUser(getNewPosts: true)
    }
    
    @IBAction func postBnAction(_ sender: UIButton) {
        if (postTv.text.isEmpty) {
            return
        }
        DispatchQueue.main.async {
            self.postTv.isEditable = false
            self.postTv.isSelectable = false
            sender.isEnabled = false
        }
        client.insertPost(username: self.getTestUser(), postText: postTv.text, location: self.getTestLocation(), completion: insertPostCompletion)
    }
    
    @objc func gestureToPopularViewAction(recognizer: UISwipeGestureRecognizer) {
        self.performSegue(withIdentifier: "seePopularSegue", sender: self)
    }
    
    private func insertPostCompletion(response: StatusOr<Response>) {
        var error: Bool = false
        if (response.hasError()) {
            // Handle likley connection error
            print("Connection Failure: " + response.getErrorMessage())
            error = true
        }
        if (!error && response.get().serverStatusCode != ServerStatusCode.OK) {
            // Handle server error
            print("ServerStatusCode: " + String(describing: response.get().serverStatusCode))
            error = true
        }
        
        if (!error) {
            print("Inserted post successfully!")
        }
        
        DispatchQueue.main.async {
            self.postTv.isEditable = true
            self.postTv.isSelectable = true
            if (!error) {
                self.postTv.text = ""
            }
            self.postBn.isEnabled = true
            self.postTableView.reloadData()
        }
    }
    
//    private func getAllPostsByUserCompletion(response: StatusOr<Response>) {
//        if (response.hasError()) {
//            // Handle likley connection error
//            print("Connection Failure: " + response.getErrorMessage())
//            return
//        }
//        if (response.get().serverStatusCode != ServerStatusCode.OK) {
//            // Handle server error
//            print("ServerStatusCode: " + String(describing: response.get().serverStatusCode))
//            return
//        }
//        allPostsByUser.append(contentsOf: response.get().posts)
//        print("Got posts..." + String(allPostsByUser.count))
//        
//        DispatchQueue.main.async {
//            self.postTableView.reloadData()
//        }
//    }
    
    private func fetchPostsAroundUserCompletion(responseOr: StatusOr<Response>) {
        if (responseOr.hasError()) {
            // Handle likley connection error
            print("Connection Failure: " + responseOr.getErrorMessage())
            return
        }
        if (!responseOr.get().ok()) {
            // Handle server error
            print("ServerStatusCode: " + String(describing: responseOr.get().serverStatusCode))
            return
        }

        fetchPostsMetadata.updateMetadata(newMetadata: responseOr.get().queryMetadata)
        allPostsAroundUser.append(contentsOf: responseOr.get().posts)
        allPostsAroundUser = allPostsAroundUser.sorted(by: {$0.creationTimestampSec > $1.creationTimestampSec})
        print("Got posts around user after fetch..." + String(responseOr.get().posts.count))
        
        DispatchQueue.main.async {
            self.postTableView.reloadData()
            
            if (self.postTableView.refreshControl != nil) {
                self.postTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    public func fetchPostsAroundUser(getNewPosts: Bool) {
        if (!getNewPosts && !(fetchPostsMetadata.hasMoreOlderData ?? true)) {
            return
        }
        let params: QueryParams = QueryParams(getNewer: getNewPosts, currTopCursorStr: self.fetchPostsMetadata.newTopCursorStr, currBottomCursorStr: self.fetchPostsMetadata.newBottomCursorStr)
        client.getAllPostsAroundUser(username: self.getTestUser(), location: self.getTestLocation(),
                                     queryParams: params, completion:fetchPostsAroundUserCompletion)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seePopularSegue") {
            // Do something here, maybe...
            return
        }
        if (segue.identifier == "seeCommentsSegue") {
            let postView: PostView = sender as! PostView
            let commentsViewController: CommentsViewController = segue.destination as! CommentsViewController
            commentsViewController.controllerInit(post: postView.post!)
            return
        }
    }
}

// Post TableView Extensions
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postViewCell") as! PostView
        cell.delegate = self
        cell.configure(post: allPostsAroundUser[indexPath.section])
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.blue.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allPostsAroundUser.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 &&
            indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            if (!allPostsAroundUser.isEmpty) {
                self.fetchPostsAroundUser(getNewPosts: false)
            }
        }
    }
}

//

