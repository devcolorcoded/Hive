//
//  ViewController.swift
//  Hive
//
//  Created by Chuck Onwuzuruike on 10/3/18.
//  Copyright © 2018 Chuck Onwuzuruike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var client: ServerClient = ServerClient()
    // All posts around user.
//    var allPostsByUser: Array<Post> = []
    var allPostsAroundUser: Array<Post> = []
    
    
    @IBOutlet weak var postTv: UITextView!
    @IBOutlet weak var postBn: UIButton!
    @IBOutlet weak var postTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPostTv()
        setupPostBn()
        setupPostTableView()
        fetchPostsAroundUser()
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
        fetchPostsAroundUser()
    }
    
    private func getTestLocation() -> String {
        return "47.608013:-122.335167"  // Seattle
    }
    
    @IBAction func postBnAction(_ sender: UIButton) {
        if (postTv.text.isEmpty) {
            return
        }
        DispatchQueue.main.async {
            self.postTv.isEditable = false
            self.postTv.isSelectable = false
        }
        client.insertPost(username: "userC", postText: postTv.text, location: getTestLocation(), completion: insertPostCompletion)
    }
    
    private func insertPostCompletion(response: StatusOr<Response>) {
        if (response.hasError()) {
            // Handle likley connection error
            print("Connection Failure: " + response.getErrorMessage())
            return
        }
        if (response.get().serverStatusCode != ServerStatusCode.OK) {
            // Handle server error
            print("ServerStatusCode: " + String(describing: response.get().serverStatusCode))
            return
        }
        print("Inserted post successfully!")
        
        DispatchQueue.main.async {
            self.postTv.isEditable = true
            self.postTv.isSelectable = true
            self.postTv.text = ""
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
    
    private func fetchPostsAroundUserCompletion(response: StatusOr<Response>) {
        if (response.hasError()) {
            // Handle likley connection error
            print("Connection Failure: " + response.getErrorMessage())
            return
        }
        if (response.get().serverStatusCode != ServerStatusCode.OK) {
            // Handle server error
            print("ServerStatusCode: " + String(describing: response.get().serverStatusCode))
            return
        }
        allPostsAroundUser.removeAll()
        allPostsAroundUser.append(contentsOf: response.get().posts)
        print("Got posts around user after fetch..." + String(allPostsAroundUser.count))
        
        DispatchQueue.main.async {
            self.postTableView.reloadData()
            
            if (self.postTableView.refreshControl != nil) {
                self.postTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func fetchPostsAroundUser() {
        client.getAllPostsAroundUser(username: "userC", location: getTestLocation(), completion:fetchPostsAroundUserCompletion)
    }
}

// --------------- Extensions ----------------

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postViewCell") as! PostViewTableViewCell
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
    
}

