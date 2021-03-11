//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Ertugrul Eryildiz on 3/2/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    let myRefreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRefreshController.addTarget(self, action: #selector(loadTweet), for: .valueChanged)
        tableView.refreshControl = myRefreshController
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150

         
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadTweet()
    }
    
    @objc func loadTweet(){
        
        numberOfTweets = 20
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams as [String : Any], success: { (tweets:[NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshController.endRefreshing()
            
        }, failure: { (Error) in
            print("couldn't retrieve tweets :((.")
        })
    }
    
    func loadMoreTweets(){
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        numberOfTweets = numberOfTweets + 20
        
        let myParams = ["count": numberOfTweets]
 
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any], success:
            { (tweets: [NSDictionary]) in
                self.tweetArray.removeAll()
            for tweet in tweets{
                self.tweetArray.append(tweet)
            }
                
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("COuld not retrieve tweets!")
        })
    
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey:"userLoggedIn")
        
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetLabel.text = (tweetArray[indexPath.row]["text"] as! String)
        
        let imageURL = URL(string: (user["profile_image_url_https"]) as! String)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data {
            cell.userImageView.image = UIImage(data: imageData)
        }
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(isRetweeted: tweetArray[indexPath.row]["retweeted"] as! Bool)
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }
}
