//
//  SettingsViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public enum SettingsRow: Int {
    case CoverImage
    case ProfileImage
    case ProfileDescription
    case CredentialSettings
    case Name
    case Bio
    case Links
    case PreferenceSettings
    case Unknown
}

public class SettingsViewController: UITableViewController, ControllerThatMightHaveTheCurrentUser {

    @IBOutlet weak public var profileImageView: UIView!
    @IBOutlet weak public var profileDescription: ElloLabel!
    var scrollLogic: ElloScrollLogic!

    public var currentUser: User? {
        didSet {
            credentialSettingsViewController?.currentUser = currentUser
            dynamicSettingsViewController?.currentUser = currentUser
        }
    }

    var credentialSettingsViewController: CredentialSettingsViewController?
    var dynamicSettingsViewController: DynamicSettingsViewController?

    override public func awakeFromNib() {
        super.awakeFromNib()
        scrollLogic = ElloScrollLogic(
            onShow: self.showNavBars,
            onHide: self.hideNavBars
        )
    }

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as! ElloTabBarController?
    }

    func showNavBars(scrollToBottom : Bool) {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }

        navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.layoutIfNeeded()
    }

    func hideNavBars() {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(true, animated: true)
        }

        navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.layoutIfNeeded()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupProfileDescription()
        setupNavigationBar()
    }

    private func setupProfileDescription() {
        let text = NSMutableAttributedString(attributedString: profileDescription.attributedText)

        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.greyA(), range: NSRange(location: 0, length: text.length))
        profileDescription.attributedText = text
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: "backAction")
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = NSLocalizedString("Settings", comment: "settings title")
        navigationItem.fixNavBarItemPadding()
    }

    func backAction() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.popViewControllerAnimated(true)
    }

    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch SettingsRow(rawValue: indexPath.row) ?? .Unknown {
        case .CoverImage: return 200
        case .ProfileImage: return 250
        case .ProfileDescription: return 130
        case .CredentialSettings: return credentialSettingsViewController?.height ?? 0
        case .Name: return 97
        case .Bio: return 200
        case .Links: return 97
        case .PreferenceSettings: return dynamicSettingsViewController?.height ?? 0
        case .Unknown: return 0
        }
    }

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier ?? "" {
        case "CredentialSettingsSegue":
            credentialSettingsViewController = segue.destinationViewController as? CredentialSettingsViewController
            credentialSettingsViewController?.currentUser = currentUser
            credentialSettingsViewController?.delegate = self

        case "DynamicSettingsSegue":
            dynamicSettingsViewController = segue.destinationViewController as? DynamicSettingsViewController
            dynamicSettingsViewController?.currentUser = currentUser

        default: break
        }
    }

    @IBAction func logOutTapped(sender: ElloTextButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedOut.rawValue, object: nil)
    }
}

extension SettingsViewController: CredentialSettingsDelegate {
    public func credentialSettingsDidUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

public extension SettingsViewController {
    class func instantiateFromStoryboard() -> SettingsViewController {
        return UIStoryboard(name: "Settings", bundle: NSBundle(forClass: AppDelegate.self)).instantiateInitialViewController() as! SettingsViewController
    }
}


// strangely, we have to "override" these delegate methods, but the parent class
// UITableViewController doesn't implement them.
extension SettingsViewController: UIScrollViewDelegate {

    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    public override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    public override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

}
