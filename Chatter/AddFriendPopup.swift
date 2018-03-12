//
//  AddFriendPopup.swift
//  Chatter
//
//  Created by Austen Ma on 3/11/18.
//  Copyright © 2018 Austen Ma. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddFriendModal: UIViewController {
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var inviteUsernameInput: UITextField!
    
    var ref: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up modal styling
        modalView.layer.cornerRadius = 5
        modalView.layer.borderWidth = 2
        modalView.layer.borderColor = UIColor(red: 179/255, green: 95/255, blue: 232/255, alpha: 1.0).cgColor
        
        // Initiate Firebase
        ref = Database.database().reference()
    }
    
    @IBAction func closeModal(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendInvite(sender: AnyObject) {
        guard let inviteUsername = inviteUsernameInput.text else {return}
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            // Iterate through users to find matching user data with username
            for user in value! {
                let inviteUserDetails = user.value as? NSDictionary
                
                if (String(describing: inviteUserDetails!["username"]!) == inviteUsername) {
                    print("FOUND USER: \(user)")
                    
                    let inviteUserID = user.key as? String
                    
                    // Send an invitation by storing an invitation property in the invited's data
                    let invitationData: [String: String] = [self.userID!: "Invitation Message Link Here!"]
                    self.ref.child("users").child(inviteUserID!).child("invitations").updateChildValues(invitationData) { (error, ref) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
}

