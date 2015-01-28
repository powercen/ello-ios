//
//  StreamDataSourceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class StreamDataSourceSpec: QuickSpec {
    override func spec() {
        
        var vc = StreamViewController.instantiateFromStoryboard()
        
        beforeEach({
            vc = StreamViewController.instantiateFromStoryboard()
            let keyWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            keyWindow.makeKeyAndVisible()
            keyWindow.rootViewController = vc
            vc.loadView()
            vc.viewDidLoad()
        })
        
        
        var dataSource: StreamDataSource!
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        let webView = UIWebView(frame: CGRectMake(0, 0, 320, 640))
        ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
        var loadedStreamables:[Streamable]?
        
        describe("initialization", {

            beforeEach({
                dataSource = StreamDataSource(testWebView: webView, streamKind: StreamKind.Friend)
                vc.dataSource = dataSource
                StreamService().loadFriendStream({ (streamables) -> () in
                    loadedStreamables = streamables
                }, failure: nil)

                dataSource.addStreamables(loadedStreamables!, completion: { (cellCount) -> () in
                    vc.collectionView.dataSource = dataSource
                    vc.collectionView.reloadData()
                }, startingIndexPath:nil)
            })

            describe("-collectionView:numberOfItemsInSection:", {

                it("returns 6", {
                    expect(dataSource.collectionView(vc.collectionView, numberOfItemsInSection: 0)).toEventually(equal(6))
                })
            })
                        
            describe("-postForIndexPath:", {
                
                it("returns a post", {
                    expect(dataSource.postForIndexPath(NSIndexPath(forItem: 0, inSection: 0))).toEventually(beAKindOf(Post.self))
                })
                
                it("returns nil when out of bounds", {
                    expect(dataSource.postForIndexPath(NSIndexPath(forItem: 100, inSection: 0))).toEventually(beNil())
                })
                
                it("returns nil when the subject is not a post", {
                    expect(dataSource.postForIndexPath(NSIndexPath(forItem: 7, inSection: 0))).toEventually(beNil())
                })
            })

            

//            describe("-collectionView:cellForItemAtIndexPath:", {
//
//                it("returns a StreamHeaderCell", {
//                    let cell = dataSource.collectionView(vc.collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
//                    expect{cell}.toEventually(beAnInstanceOf(StreamHeaderCell.self))
//
//                })
//            })
        })
    }
}
