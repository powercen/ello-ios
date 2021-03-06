//
//  UserAvatarsCellPresenter.swift
//  Ello
//
//  Created by Ryan Boyajian on 6/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public struct UserAvatarsCellPresenter {

    public static func configure(
        cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: NSIndexPath,
        currentUser: User?)
    {
        if let cell = cell as? UserAvatarsCell,
            model = streamCellItem.jsonable as? UserAvatarCellModel
        {
            cell.imageView.image = model.icon.normalImage
            cell.userAvatarCellModel = model
            cell.loadingLabel.hidden = model.hasUsers
        }
    }
}
