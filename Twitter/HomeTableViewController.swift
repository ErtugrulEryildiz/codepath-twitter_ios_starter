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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweet()

    }

    func loadTweet(){
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": 10]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets:[NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("couldn't retrieve tweets :((.")
        })
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey:"userLoggedIn")
        
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as! String
        cell.tweetLabel.text = (tweetArray[indexPath.row]["text"] as! String)
        
        let imageURL = URL(string: (user["profile_image_url_https"]) as! String)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data {
            cell.userImageView.image = UIImage(data: imageData)
        }
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
