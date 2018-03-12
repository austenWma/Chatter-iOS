//
//  Menu.swift
//  Chatter
//
//  Created by Austen Ma on 2/26/18.
//  Copyright © 2018 Austen Ma. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Menu: UIViewController, SwitchMenuFriendsViewDelegate {
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet var menuView: UIView!
    
    var interactor:Interactor? = nil
    var menuActionDelegate:MenuActionDelegate? = nil
    let menuItems = ["First", "Second"]
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MenuView {
            destination.switchDelegate = self
        }
        
        if let destination = segue.destination as? FriendsView {
            destination.switchDelegate = self
        }
    }

    func SwitchMenuFriendsView(toPage: String) {
        if (toPage == "friendsView") {
            UIView.animate(withDuration: 0.5, animations: {
                self.menuView.alpha = 0.0
                self.friendsView.alpha = 1.0
            })
        }   else {
            UIView.animate(withDuration: 0.5, animations: {
                self.menuView.alpha = 1.0
                self.friendsView.alpha = 0.0
            })
        }
    }
    
    // SLIDE MENU FUNCTIONALITY -----------------------------------------------------------------------------------------------------
    
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .left)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeMenu(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true){
            self.delay(seconds: 0.5){
                self.menuActionDelegate?.reopenMenu()
            }
        }
    }
    
}

extension Menu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
}

extension Menu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            menuActionDelegate?.openSegue("openFirst", sender: nil)
        case 1:
            menuActionDelegate?.openSegue("openSecond", sender: nil)
        default:
            break
        }
    }
}

