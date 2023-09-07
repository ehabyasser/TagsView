# TagsView


![Simulator Screenshot - iPhone 14 Pro - 2023-09-07 at 14 01 41](https://github.com/ehabyasser/TagsView/assets/17433385/725902de-4314-44a2-b474-affd10842879)
![Simulator Screenshot - iPhone 14 Pro - 2023-09-07 at 14 01 20](https://github.com/ehabyasser/TagsView/assets/17433385/a98f3c13-8abf-4e7d-8b83-ad2fac3d45f1)
![Simulator Screenshot - iPhone 14 Pro - 2023-09-07 at 14 01 04](https://github.com/ehabyasser/TagsView/assets/17433385/c35a7b64-daf4-419c-9765-abfe5b176bff)
![Simulator Screenshot - iPhone 14 Pro - 2023-09-07 at 14 00 52](https://github.com/ehabyasser/TagsView/assets/17433385/e210f064-5edd-4e65-b95e-1297157cb78c)

How to use it:

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
