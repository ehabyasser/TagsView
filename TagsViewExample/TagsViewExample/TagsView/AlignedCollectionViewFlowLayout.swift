//
//  AlignedCollectionViewFlowLayout.swift
//  TagsViewExample
//
//  Created by Ihab yasser on 07/09/2023.
//

import Foundation
import UIKit

protocol Alignment {}

public enum HorizontalAlignment: Alignment {
    case left
    case right
    case leading
    case trailing
    case justified
}

public enum VerticalAlignment: Alignment {
    case top
    case center
    case bottom
}

private enum EffectiveHorizontalAlignment: Alignment {
    case left
    case right
    case justified
}

/// Describes an axis with respect to which items can be aligned.
private struct AlignmentAxis<A: Alignment> {
    
    let alignment: A
    let position: CGFloat
}



open class AlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
   
    public var horizontalAlignment: HorizontalAlignment = .justified

    public var verticalAlignment: VerticalAlignment = .center

    fileprivate var effectiveHorizontalAlignment: EffectiveHorizontalAlignment {

        var trivialMapping: [HorizontalAlignment: EffectiveHorizontalAlignment] {
            return [
                .left: .left,
                .right: .right,
                .justified: .justified
            ]
        }

        let layoutDirection = UIApplication.shared.userInterfaceLayoutDirection

        switch layoutDirection {
        case .leftToRight:
            switch horizontalAlignment {
            case .leading:
                return .left
            case .trailing:
                return .right
            default:
                break
            }

        case .rightToLeft:
            switch horizontalAlignment {
            case .leading:
                return .right
            case .trailing:
                return .left
            default:
                break
            }
        default:
            break
        }

        return trivialMapping[horizontalAlignment]!
    }
    
    fileprivate var alignmentAxis: AlignmentAxis<HorizontalAlignment>? {
        switch effectiveHorizontalAlignment {
        case .left:
            return AlignmentAxis(alignment: HorizontalAlignment.left, position: sectionInset.left)
        case .right:
            guard let collectionViewWidth = collectionView?.frame.size.width else {
                return nil
            }
            return AlignmentAxis(alignment: HorizontalAlignment.right, position: collectionViewWidth - sectionInset.right)
        default:
            return nil
        }
    }
    
    /// The width of the area inside the collection view that can be filled with cells.
    private var contentWidth: CGFloat? {
        guard let collectionViewWidth = collectionView?.frame.size.width else {
            return nil
        }
        return collectionViewWidth - sectionInset.left - sectionInset.right
    }
    

    public init(horizontalAlignment: HorizontalAlignment = .justified, verticalAlignment: VerticalAlignment = .center) {
        super.init()
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        if horizontalAlignment != .justified {
            layoutAttributes.alignHorizontally(collectionViewLayout: self)
        }
        if verticalAlignment != .center {
            layoutAttributes.alignVertically(collectionViewLayout: self)
        }
        
        return layoutAttributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // We may not change the original layout attributes or UICollectionViewFlowLayout might complain.
        let layoutAttributesObjects = copy(super.layoutAttributesForElements(in: rect))
        layoutAttributesObjects?.forEach({ (layoutAttributes) in
            setFrame(forLayoutAttributes: layoutAttributes)
        })
        return layoutAttributesObjects
    }
    
    
    // MARK: - 👷 Private layout helpers
    
    /// Sets the frame for the passed layout attributes object by calling the `layoutAttributesForItem(at:)` function.
    private func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.representedElementCategory == .cell { // Do not modify header views etc.
            let indexPath = layoutAttributes.indexPath
            if let newFrame = layoutAttributesForItem(at: indexPath)?.frame {
                layoutAttributes.frame = newFrame
            }
        }
    }
    
    /// A function to access the `super` implementation of `layoutAttributesForItem(at:)` externally.
    ///
    /// - Parameter indexPath: The index path of the item for which to return the layout attributes.
    /// - Returns: The unmodified layout attributes for the item at the specified index path
    ///            as computed by `UICollectionViewFlowLayout`.
    fileprivate func originalLayoutAttribute(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    

    fileprivate func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes, inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let lineWidth = contentWidth else {
            return false
        }
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(x: sectionInset.left,
                               y: firstItemFrame.origin.y,
                               width: lineWidth,
                               height: firstItemFrame.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }
    

    fileprivate func layoutAttributes(forItemsInLineWith layoutAttributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
        guard let lineWidth = contentWidth else {
            return [layoutAttributes]
        }
        var lineFrame = layoutAttributes.frame
        lineFrame.origin.x = sectionInset.left
        lineFrame.size.width = lineWidth
        return super.layoutAttributesForElements(in: lineFrame) ?? []
    }
    

    private func verticalAlignmentAxisForLine(with layoutAttributes: [UICollectionViewLayoutAttributes]) -> AlignmentAxis<VerticalAlignment>? {
        
        guard let firstAttribute = layoutAttributes.first else {
            return nil
        }
        
        switch verticalAlignment {
        case .top:
            let minY = layoutAttributes.reduce(CGFloat.greatestFiniteMagnitude) { min($0, $1.frame.minY) }
            return AlignmentAxis(alignment: .top, position: minY)
            
        case .bottom:
            let maxY = layoutAttributes.reduce(0) { max($0, $1.frame.maxY) }
            return AlignmentAxis(alignment: .bottom, position: maxY)
            
        default:
            let centerY = firstAttribute.center.y
            return AlignmentAxis(alignment: .center, position: centerY)
        }
    }
    

    fileprivate func verticalAlignmentAxis(for currentLayoutAttributes: UICollectionViewLayoutAttributes) -> AlignmentAxis<VerticalAlignment> {
        let layoutAttributesInLine = layoutAttributes(forItemsInLineWith: currentLayoutAttributes)
        // It's okay to force-unwrap here because we pass a non-empty array.
        return verticalAlignmentAxisForLine(with: layoutAttributesInLine)!
    }
    

    private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
    }
    
}




fileprivate extension UICollectionViewLayoutAttributes {
    
    private var currentSection: Int {
        return indexPath.section
    }
    
    private var currentItem: Int {
        return indexPath.item
    }
    
    /// The index path for the item preceding the item represented by this layout attributes object.
    private var precedingIndexPath: IndexPath {
        return IndexPath(item: currentItem - 1, section: currentSection)
    }
    
    /// The index path for the item following the item represented by this layout attributes object.
    private var followingIndexPath: IndexPath {
        return IndexPath(item: currentItem + 1, section: currentSection)
    }
    
    /// Checks if the item represetend by this layout attributes object is the first item in the line.
    ///
    /// - Parameter collectionViewLayout: The layout for which to perform the check.
    /// - Returns: `true` if the represented item is the first item in the line, else `false`.
    func isRepresentingFirstItemInLine(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
        if currentItem <= 0 {
            return true
        }
        else {
            if let layoutAttributesForPrecedingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: precedingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForPrecedingItem)
            }
            else {
                return true
            }
        }
    }
    
    /// Checks if the item represetend by this layout attributes object is the last item in the line.
    ///
    /// - Parameter collectionViewLayout: The layout for which to perform the check.
    /// - Returns: `true` if the represented item is the last item in the line, else `false`.
    func isRepresentingLastItemInLine(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
        guard let itemCount = collectionViewLayout.collectionView?.numberOfItems(inSection: currentSection) else {
            return false
        }
        
        if currentItem >= itemCount - 1 {
            return true
        }
        else {
            if let layoutAttributesForFollowingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: followingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForFollowingItem)
            }
            else {
                return true
            }
        }
    }
    
    /// Moves the layout attributes object's frame so that it is aligned horizontally with the alignment axis.
    func align(toAlignmentAxis alignmentAxis: AlignmentAxis<HorizontalAlignment>) {
        switch alignmentAxis.alignment {
        case .left:
            frame.origin.x = alignmentAxis.position
        case .right:
            frame.origin.x = alignmentAxis.position - frame.size.width
        default:
            break
        }
    }
    
    /// Moves the layout attributes object's frame so that it is aligned vertically with the alignment axis.
    func align(toAlignmentAxis alignmentAxis: AlignmentAxis<VerticalAlignment>) {
        switch alignmentAxis.alignment {
        case .top:
            frame.origin.y = alignmentAxis.position
        case .bottom:
            frame.origin.y = alignmentAxis.position - frame.size.height
        default:
            center.y = alignmentAxis.position
        }
    }
    
    /// Positions the frame right of the preceding item's frame, leaving a spacing between the frames
    /// as defined by the collection view layout's `minimumInteritemSpacing`.
    ///
    /// - Parameter collectionViewLayout: The layout on which to perfom the calculations.
    private func alignToPrecedingItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
            frame.origin.x = precedingItemAttributes.frame.maxX + itemSpacing
        }
    }
    
    /// Positions the frame left of the following item's frame, leaving a spacing between the frames
    /// as defined by the collection view layout's `minimumInteritemSpacing`.
    ///
    /// - Parameter collectionViewLayout: The layout on which to perfom the calculations.
    private func alignToFollowingItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        
        if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
            frame.origin.x = followingItemAttributes.frame.minX - itemSpacing - frame.size.width
        }
    }
    
    /// Aligns the frame horizontally as specified by the collection view layout's `horizontalAlignment`.
    ///
    /// - Parameters:
    ///   - collectionViewLayout: The layout providing the alignment information.
    func alignHorizontally(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        
        guard let alignmentAxis = collectionViewLayout.alignmentAxis else {
            return
        }
        
        switch collectionViewLayout.effectiveHorizontalAlignment {
            
        case .left:
            if isRepresentingFirstItemInLine(collectionViewLayout: collectionViewLayout) {
                align(toAlignmentAxis: alignmentAxis)
            } else {
                alignToPrecedingItem(collectionViewLayout: collectionViewLayout)
            }
            
        case .right:
            if isRepresentingLastItemInLine(collectionViewLayout: collectionViewLayout) {
                align(toAlignmentAxis: alignmentAxis)
            } else {
                alignToFollowingItem(collectionViewLayout: collectionViewLayout)
            }
            
        default:
            return
        }
    }
    
    /// Aligns the frame vertically as specified by the collection view layout's `verticalAlignment`.
    ///
    /// - Parameter collectionViewLayout: The layout providing the alignment information.
    func alignVertically(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        let alignmentAxis = collectionViewLayout.verticalAlignmentAxis(for: self)
        align(toAlignmentAxis: alignmentAxis)
    }
    
}
