//
//  ViewController.swift
//  TagsViewExample
//
//  Created by Ihab yasser on 07/09/2023.
//

import UIKit

class ViewController: UIViewController {
    
    private let tagsView:TagsView = {
        let tagsView = TagsView()
        tagsView.isRTL = true
        tagsView.isVertical = false
        //tagsView.tagsViewHeight = 400
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        tagsView.tagBackgroundColor = .brown
        tagsView.tagTextColor = .white
        tagsView.closeBtnColor = .white
        tagsView.padding = 8
        return tagsView
    }()

    var tags:[String] = ["Vegetables" , "Dairy Products" , "Meat" , "Seafood" , "Bread" , "Legume" , "Condiment" , "Confectionery" , "Desserts" , "Baked goods"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tagsView)
        tagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tagsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        tagsView.tags = tags
        tagsView.closeBtnActionCallback = { tag , index in
            print(tag , index)
        }
    }


}

