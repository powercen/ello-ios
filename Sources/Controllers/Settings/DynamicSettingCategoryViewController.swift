//
//  DynamicSettingCategoryViewController.swift
//  Ello
//
//  Created by Tony DiPasquale on 4/13/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class DynamicSettingCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ControllerThatMightHaveTheCurrentUser {
    var category: DynamicSettingCategory?
    var currentUser: User?
    @IBOutlet weak var tableView: UITableView!
    weak var navBar: ElloNavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.label
        setupTableView()
        setupNavigationBar()
    }

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.registerNib(UINib(nibName: "DynamicSettingCell", bundle: .None), forCellReuseIdentifier: "DynamicSettingCell")
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(DynamicSettingCategoryViewController.backAction))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = category?.label
        navigationItem.fixNavBarItemPadding()
        navBar.items = [navigationItem]
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }

    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.settings.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DynamicSettingCell", forIndexPath: indexPath) as! DynamicSettingCell

        if  let setting = category?.settings.safeValue(indexPath.row),
            let user = currentUser
        {
            DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
            cell.setting = setting
            cell.delegate = self
        }
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if  let setting = category?.settings.safeValue(indexPath.row),
            let user = currentUser
        {
            let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)
            if !isVisible {
                return 0
            }
        }

        return UITableViewAutomaticDimension
    }
}

extension DynamicSettingCategoryViewController: DynamicSettingCellDelegate {

    typealias SettingConfig = (setting: DynamicSetting, indexPath: NSIndexPath, value: Bool, isVisible: Bool)

    func toggleSetting(setting: DynamicSetting, value: Bool) {
        guard let nav = self.navigationController as? ElloNavigationController,
            currentUser = currentUser,
            category = self.category else { return }
        let settings = category.settings

        let visibility = settings.enumerate().map { (index, setting) in
            return (
                setting: setting,
                indexPath: NSIndexPath(forRow: index, inSection: 0),
                value: currentUser.propertyForSettingsKey(setting.key),
                isVisible: DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: currentUser)
            )
        }

        var updatedValues: [String: AnyObject] = [
            setting.key: value,
        ]

        for anotherSetting in category.settings {
            if let anotherValue = setting.sets(anotherSetting, when: value) {
                updatedValues[anotherSetting.key] = anotherValue
            }
        }

        ProfileService().updateUserProfile(updatedValues,
            success: { user in
                nav.setProfileData(user)

                let changedPaths = visibility.filter { config in
                    return self.settingChanged(config, user: user)
                }.map { config in
                    return config.indexPath
                }

                self.tableView.reloadRowsAtIndexPaths(changedPaths, withRowAnimation: .Automatic)
            },
            failure: { (_, _) in
                self.tableView.reloadData()
            })
    }

    private func settingChanged(config: SettingConfig, user: User) -> Bool {
        let setting = config.setting
        let currVisibility = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)
        let currValue = user.propertyForSettingsKey(setting.key)
        return config.isVisible != currVisibility || config.value != currValue
    }

    func deleteAccount() {
        let vc = DeleteAccountConfirmationViewController()
        presentViewController(vc, animated: true, completion: .None)
    }
}
