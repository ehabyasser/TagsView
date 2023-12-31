//
//  TagsView.swift
//  TagsView
//
//  Created by Ihab yasser on 30/08/2023.
//

import Foundation
import UIKit

//TagsView
class TagsView:UIView {
    
    private let TagsCV:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero , collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    var tags:[String]?{
        didSet {
            if tags != nil {
                TagsCV.reloadData()
            }
        }
    }
    
    var isRTL:Bool? {
        didSet{
            guard let isRTL = isRTL else {return}
            if isVertical == true {
                let alignedFlowLayout = AlignedCollectionViewFlowLayout(
                    horizontalAlignment: isRTL ? .right : .left,
                    verticalAlignment: .top
                )
                alignedFlowLayout.scrollDirection = isVertical == true ? .vertical : .horizontal
                TagsCV.collectionViewLayout = alignedFlowLayout
            }else {
                if isRTL {
                    let layout = UICollectionViewFlowLayout()
                    layout.scrollDirection = .horizontal
                    TagsCV.semanticContentAttribute = .forceRightToLeft
                    TagsCV.collectionViewLayout = layout
                }
            }
        }
    }
    
    var padding:CGFloat? {
        didSet{
            guard let padding = padding else {return}
            TagsCV.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
    }
    
    var leftPadding:CGFloat? {
        didSet{
            guard let leftPadding = leftPadding else {return}
            TagsCV.contentInset = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
        }
    }
    
    var rightPadding:CGFloat? {
        didSet{
            guard let rightPadding = rightPadding else {return}
            TagsCV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightPadding)
        }
    }
    
    
    var topPadding:CGFloat? {
        didSet{
            guard let topPadding = topPadding else {return}
            TagsCV.contentInset = UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
        }
    }
    
    var bottomPadding:CGFloat? {
        didSet{
            guard let bottomPadding = bottomPadding else {return}
            TagsCV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0)
        }
    }
    
    var isVertical:Bool? {
        didSet{
            guard let isVertical = isVertical else {return}
            if isVertical{
                let alignedFlowLayout = AlignedCollectionViewFlowLayout(
                    horizontalAlignment: isRTL == true ? .right : .left,
                    verticalAlignment: .top
                )
                alignedFlowLayout.scrollDirection =  isVertical ? .vertical : .horizontal
                TagsCV.collectionViewLayout = alignedFlowLayout
            }else {
                if isRTL == true {
                    let layout = UICollectionViewFlowLayout()
                    layout.scrollDirection = .horizontal
                    TagsCV.semanticContentAttribute = .forceRightToLeft
                    TagsCV.collectionViewLayout = layout
                }
            }
        }
    }
    
    var tagsViewHeight:CGFloat = 50
    
    var enableCloseButton:Bool = true
    
    var closeBtnColor: UIColor = .label
    
    var closeBtnIcon:UIImage? = UIImage(systemName: "multiply")
    
    var closeBtnActionCallback: ((String , Int) -> ())? = nil
    
    var tagTextColor: UIColor = .label
    
    var tagBackgroundColor: UIColor = .white
    
    var font:UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    
    func removeTag(index:Int){
        if (tags?.count ?? 0) > index {
            tags?.remove(at: index)
        }
        reloadTagsView()
    }
    
    func removeTag(_ tag:String){
        if let index = tags?.firstIndex(of: tag) {
            removeTag(index: index)
        }
    }
    
    func removeAllTags(){
        tags?.removeAll()
        reloadTagsView()
    }
    
    func addTag(_ tag:String){
        initTags()
        tags?.append(tag)
        reloadTagsView()
    }
    
    func addTags(tags:[String]){
        initTags()
        self.tags?.append(contentsOf: tags)
        reloadTagsView()
    }
    
    func addTagAt(index:Int , tag:String){
        initTags()
        if (self.tags?.count ?? 0) > index {
            self.tags?.insert(tag, at: index)
            reloadTagsView()
        }
    }
    
    private func initTags(){
        if self.tags == nil {
            self.tags = []
        }
    }
    
    private func reloadTagsView(){
        TagsCV.reloadData()
    }
    
    init(){
        super.init(frame: .zero)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setupViews(){
        self.addSubview(TagsCV)
        TagsCV.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        TagsCV.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        TagsCV.topAnchor.constraint(equalTo: topAnchor).isActive = true
        TagsCV.register(TagsCell.self, forCellWithReuseIdentifier: "TagsCell")
        TagsCV.dataSource = self
        TagsCV.delegate = self
    }
    
    
    override func layoutSubviews() {
        if (isVertical == nil || isVertical == false) {
            if tagsViewHeight > 50 {
                TagsCV.heightAnchor.constraint(equalToConstant: tagsViewHeight + 10).isActive = true
            }else{
                TagsCV.heightAnchor.constraint(equalToConstant:  60).isActive = true
            }
        }else {
            TagsCV.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
}


private class TagsCell:UICollectionViewCell {
    
    let tagBackground:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        return view
    }()
    
    let tagLbl:UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .left
        return lbl
    }()
    
    
    let closeBtn:UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var tagTitle:String?{
        didSet{
            tagLbl.text = tagTitle
        }
    }
    
    var isRTL:Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func loadViews(){
        contentView.addSubview(tagBackground)
        tagBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        tagBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        tagBackground.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tagBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        tagBackground.addSubview(closeBtn)
        tagBackground.addSubview(tagLbl)
        
        if isRTL {
            tagLbl.leadingAnchor.constraint(equalTo: closeBtn.trailingAnchor , constant: 4).isActive = true
            tagLbl.trailingAnchor.constraint(equalTo: tagBackground.trailingAnchor , constant: -4).isActive = true
            closeBtn.leadingAnchor.constraint(equalTo: tagBackground.leadingAnchor , constant: 8).isActive = true
        }else{
            tagLbl.leadingAnchor.constraint(equalTo: tagBackground.leadingAnchor , constant: 4).isActive = true
            tagLbl.trailingAnchor.constraint(equalTo: closeBtn.leadingAnchor , constant: -4).isActive = true
            closeBtn.trailingAnchor.constraint(equalTo: tagBackground.trailingAnchor , constant: -8).isActive = true
        }
        closeBtn.heightAnchor.constraint(equalToConstant: 12).isActive = true
        closeBtn.centerYAnchor.constraint(equalTo: tagBackground.centerYAnchor).isActive = true
        closeBtn.widthAnchor.constraint(equalToConstant: 12).isActive = true
        
        tagLbl.centerYAnchor.constraint(equalTo: tagBackground.centerYAnchor).isActive = true
    }
    
}


extension TagsView:UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
   
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags?.count ?? 0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCell", for: indexPath) as! TagsCell
        cell.tagLbl.font = font
        cell.tagLbl.textColor = tagTextColor
        cell.closeBtn.tintColor = closeBtnColor
        cell.closeBtn.setImage(closeBtnIcon, for: .normal)
        cell.closeBtn.tag = indexPath.row
        cell.closeBtn.isHidden = !enableCloseButton
        cell.closeBtn.isUserInteractionEnabled = enableCloseButton
        cell.tagBackground.backgroundColor = tagBackgroundColor
        cell.closeBtn.addTarget(self, action: #selector(removeTagBtnDidTapped(sender:)), for: .touchUpInside)
        cell.tagTitle = tags?[indexPath.row] ?? ""
        return cell
    }
    
    @objc func removeTagBtnDidTapped(sender:UIButton){
        let removedTag = tags?[sender.tag] ?? ""
        removeTag(index: sender.tag)
        closeBtnActionCallback?(removedTag , sender.tag)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    internal  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calculateLabelWidth(for: tags?[indexPath.row] ?? "", font: font, padding: 12)
        return CGSize(width: width, height: tagsViewHeight > 50 ? tagsViewHeight : 50)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //to implement multiple selections
    }
    
    private func calculateLabelWidth(for content: String, font: UIFont?, padding: CGFloat) -> CGFloat {
        let label = UILabel()
        label.font = font
        label.text = content
        label.sizeToFit()
        return label.frame.width + 30
    }
}
