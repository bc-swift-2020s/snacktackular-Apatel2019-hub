//
//  ViewController.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/23/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn

class SpotsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var spots: Spots!
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        spots = Spots()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spots.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]

        let currentUser = authUI.auth?.currentUser
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSpot" {
            let destination = segue.destination as! SpotDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.spot = spots.spotArray[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI.signOut()
            print("*** Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
    
}

extension SpotsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotsTableViewCell
        cell.nameLabel.text = spots.spotArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension SpotsListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            tableView.isHidden = false
            print("*** We signed in with the user \(user.email ?? "unkown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInSets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInSets, y: imageY, width: self.view.frame.width - (marginInSets*2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        return loginViewController
    }
}
