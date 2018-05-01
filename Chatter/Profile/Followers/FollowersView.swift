//
//  FollowersViewController
//  Chatter
//
//  Created by Austen Ma on 3/11/18.
//  Copyright © 2018 Austen Ma. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FollowersView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var backToMenuButton: UIButton!
    @IBOutlet weak var followerTableView: UITableView!
    
    var switchDelegate:SwitchMenuFollowersViewDelegate?
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    var followerArray: [LandingRecord.friendItem]!
    var followerLabelArray: [String]!
    var followerIDArray: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        followerTableView.delegate = self
        followerTableView.dataSource = self
        
        RerenderFollowersTableView()
        SetFollowersObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackToMenu(sender: AnyObject) {
        backToMenuButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 1.25,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.40),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.backToMenuButton.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
        
        switchDelegate?.SwitchMenuFollowersView(toPage: "menuView")
    }
    
    func RerenderFollowersTableView() {
        // TODO: Debug the Followers List with a SET instead of Arrays to prevent duplicates
        
        self.followerLabelArray = []
        self.followerIDArray = []
        
        // Grab the invites array from DB
        self.ref.child("users").child(userID!).child("follower").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if (value != nil) {
                for user in value! {
                    let followerID = user.key as? String
                    
                    // Retrieve username with ID
                    self.ref.child("users").child(followerID!).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                        let followerUsername = snapshot.value as? String
                        
                        if (!self.followerLabelArray.contains(followerUsername!)) {
                            self.followerLabelArray.append(followerUsername!)
                            self.followerIDArray.append(followerID!)
                            
                            // Send notification with FollowerSet to composeModal
                            // ************* Implement profileImages
                            let tempUIView = UIView()
                            let currFollowerItem = LandingRecord.friendItem(userID: followerID!, userName: followerUsername!, profileImage: tempUIView)

                            NotificationCenter.default.post(name: .sendToComposeModalFriendsList, object: nil, userInfo: ["userData": currFollowerItem])
                        }
                        
                        // Populate the Table View as the invitations are loaded
                        self.followerTableView.reloadData()
                    })  { (error) in
                        print(error.localizedDescription)
                    }
                }
            }   else {
                self.followerTableView.reloadData()
            }
        })  { (error) in
            print(error.localizedDescription)
        }
    }
    
    func SetFollowersObserver() {
        self.ref.child("users").child(userID!).child("follower").observe(.childAdded, with: { (snapshot) in
            
            self.RerenderFollowersTableView()
            
            // Send notification to re-render follower tableView
            NotificationCenter.default.post(name: .invitationAcceptedRerender, object: nil)
        })
    }
    
    // Table View Methods --------------------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followerLabelArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersTableViewCell") as! FollowersTableViewCell
        
        // To turn off darken on select
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        // Allow button clicks on cells
        cell.contentView.isUserInteractionEnabled = true
        
        // Styling the Cell
        cell.frame.size.height = 100
        cell.followerUsernameLabel.text = followerLabelArray[indexPath.row]
        let firstnameLetter = String(describing: followerLabelArray[indexPath.row].first!).uppercased()
        cell.followerUsernameFirstLetter = firstnameLetter
        cell.followerUserID = followerIDArray[indexPath.row]
        
        let randomColor = generateRandomColor()
        let currCellAvatarView = cell.followerAvatarView
        configureAvatarView(button: currCellAvatarView!, color: randomColor)
        return cell
    }
    
    func configureAvatarView(button: UIView, color: UIColor) {
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.backgroundColor = color
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.8 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
}

