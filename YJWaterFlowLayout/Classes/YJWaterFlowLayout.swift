//
//  YJWaterFlowLayout.swift
//  WaterFlowCollectionView
//
//  Created by ddn on 16/9/20.
//  Copyright © 2016年 张永俊. All rights reserved.
//

import UIKit

fileprivate func > (left: CGSize, right: CGSize) ->Bool {
    return left.width > right.width && left.height > right.height
}

fileprivate func - (left: CGSize, right: CGSize) ->CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

@objc public protocol YJWaterLayoutDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //itemSize大小，必须实现
    func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: YJWaterFlowLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
	
    //头视图大小
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                                        sizeForHeaderInSection section: NSInteger) -> CGSize
    
    //脚视图大小
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                                        sizeForFooterInSection section: NSInteger) -> CGSize
    
    //内边距
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                                        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets
    
    //同一流中item间距
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                                        minimumItemSpacingForSection section: NSInteger) -> CGFloat
    
    //流间距
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                                        minimumWaterSpacingForSection section: NSInteger) -> CGFloat
}

public protocol YJWaterLayoutModelable {
	var size: CGSize {get}
}

public protocol YJWaterLayoutMovable: class {
	@available(iOS 9.0, *)
	func enableMoveItem (_ layout: YJWaterFlowLayout) -> Bool
	func itemLayoutDatas (layout collectionViewLayout: YJWaterFlowLayout) -> [YJWaterLayoutModelable]
}

public enum YJCollectionViewLayoutDirection : NSInteger {
	
    case vertical
    
    case horizontal
}


public let YJCollectionSectionHeader = "YJCollectionSectionHeader"
public let YJCollectionSectionFooter = "YJCollectionSectionFooter"

open class YJWaterFlowLayout: UICollectionViewLayout {
    
    //瀑布流的条数
    public var waterCount: NSInteger = 2 {
        didSet{
            invalidateLayout()
        }}
    
    //流间距（优先级低于代理方法中的设置）
    public var minimumWaterSpacing: CGFloat = 10.0 {
        didSet{
            invalidateLayout()
        }}
    
    //同一流中item间距（优先级低于代理方法中的设置）
    public var minimumItemSpacing: CGFloat = 10.0 {
        didSet{
            invalidateLayout()
        }}
    
    //section头视图大小（优先级低于代理方法中的设置，并且如果是纵向布局，宽度固定为collectionView宽度，横向亦然）
    public var headerSize: CGSize = CGSize.zero {
        didSet{
            invalidateLayout()
        }}
    
    //section脚视图大小（优先级低于代理方法中的设置，并且如果是纵向布局，宽度固定为collectionView宽度，横向亦然）
    public var footerSize: CGSize = CGSize.zero {
        didSet{
            invalidateLayout()
        }}
    
    //section内边距（优先级低于代理方法中的设置）
    public var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet{
            invalidateLayout()
        }}
    
    //流动方向
    public var layoutDirection: YJCollectionViewLayoutDirection = .vertical {
        didSet{
            invalidateLayout()
        }}
    
    //批量布局个数
    public var unionSize = 20
    
    //代理
    public weak var delegate: YJWaterLayoutDelegate?
	public weak var moveAction: YJWaterLayoutMovable?
	
	fileprivate var itemLayoutDatas: [YJWaterLayoutModelable]?
	
	@available(iOS 9.0, *)
	open func moveItem( _ resource: inout [YJWaterLayoutModelable], moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		let temp = resource.remove(at: sourceIndexPath.item)
		resource.insert(temp, at: destinationIndexPath.item)
		
		if longGes.state == .ended {
			resource = itemLayoutDatas!
		}
	}
	
    
    fileprivate var itemSizes = [CGSize]()
    fileprivate var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    fileprivate var allItemAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var headerAttributes = [Int : UICollectionViewLayoutAttributes]()
    fileprivate var footerAttributes = [Int : UICollectionViewLayoutAttributes]()
    fileprivate var unionRects = [CGRect]()
    
    fileprivate var waterWidth: CGFloat = 0.0
	
	@available(iOS 9.0, *)
	fileprivate lazy var longGes: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
	
	fileprivate var enableMove: Bool = false {
		didSet {
			if enableMove == oldValue {
				return
			}
			if #available(iOS 9.0, *) {
				if enableMove == false {
					collectionView?.removeGestureRecognizer(longGes)
				} else {
					collectionView?.addGestureRecognizer(longGes)
				}
			}
		}
	}
	
    open override func prepare() {
        super.prepare()
        guard let _ = self.delegate else {
            return
        }
		
		guard let collectionView = self.collectionView else {
			return
		}
        
        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        reset()
        
        var idx = 0
        while idx < waterCount {
            itemSizes.append(CGSize.zero)
            idx += 1
        }
        
        var size: CGSize = CGSize.zero
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0..<numberOfSections {
            //获取两个最小
            var minimumItemSpacing: CGFloat = 0.0
            var minimumWaterSpacing: CGFloat = 0.0
            getMinimumSpacing(waterSpacing: &minimumWaterSpacing, itemSpacing: &minimumItemSpacing, for: section)
            
            //获取每条流的宽度
            waterWidth = getWaterWidth()
            
            //header
            layoutHeaders(totalSize: &size, attributes: &attributes, for: section)
            
            //item
            layoutItems(totalSize: &size, attributes: &attributes, minimumWaterSpacing: minimumWaterSpacing, minimumItemSpacing: minimumItemSpacing, for: section)
            
            //footer
            layoutFooters(totalSize: &size, attributes: &attributes, minimumWaterSpacing: minimumWaterSpacing, minimumItemSpacing: minimumItemSpacing, for: section)
        }
        
        idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            
            idx += 1
        }
    }
    
    open override var collectionViewContentSize: CGSize {
        let numberOfSections = collectionView!.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
		return layoutDirection == .vertical ? itemSizes[0] - (footerAttributes.count == 0 ? CGSize(width: 0, height: minimumItemSpacing) : CGSize.zero) : itemSizes[0] - (footerAttributes.count == 0 ? CGSize(width: minimumItemSpacing, height: 0) : CGSize.zero)
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }
        if indexPath.item >= sectionItemAttributes[indexPath.section].count {
            return nil
        }
        let list = sectionItemAttributes[indexPath.section]
        let attr = list[indexPath.item]
        
        return attr
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == YJCollectionSectionHeader {
            attribute = headerAttributes[indexPath.section]!
        } else if elementKind == YJCollectionSectionFooter {
            attribute = footerAttributes[indexPath.section]!
        }
        return attribute
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count
        var attrs = [UICollectionViewLayoutAttributes]()
        
        for i in 0..<end {
            if rect.intersects(unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        
        for i in (0..<unionRects.count).reversed() {
            
            if rect.intersects(unionRects[i]) {
                end = min((i+1)*unionSize, allItemAttributes.count)
                break
            }
        }
        
        for i in begin..<end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return attrs
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        if newBounds.size != oldBounds.size {
            return true
        }
        return false
    }
    
}

extension YJWaterFlowLayout {
    
    fileprivate func shortestIndex() -> Int {
        var index = 0
        var shortestLength = Float.infinity
        
        for (idx, obj) in itemSizes.enumerated() {
            let length = layoutDirection == .vertical ? obj.height : obj.width
            if Float(length) < shortestLength {
                shortestLength = Float(length)
                index = idx
            }
        }
        return index
    }
    
    fileprivate func longestIndex() -> Int {
        var index = 0
        var longestLength: CGFloat = 0.0
        
        for (idx, obj) in itemSizes.enumerated() {
            let length = CGFloat(layoutDirection == .vertical ? obj.height : obj.width)
            if (length > longestLength){
                longestLength = length
                index = idx
            }
        }
        return index
    }
    
    fileprivate func getMinimumSpacing(waterSpacing: inout CGFloat, itemSpacing: inout CGFloat, for section: Int) {
		
        if let spacing = delegate?.collectionView?(collectionView!, layout: self, minimumItemSpacingForSection: section) {
            itemSpacing = spacing
        } else {
            itemSpacing = self.minimumItemSpacing
        }
        
        if let spacing = delegate?.collectionView?(collectionView!, layout: self, minimumWaterSpacingForSection: section) {
            waterSpacing = spacing
        } else {
            waterSpacing = self.minimumWaterSpacing
        }
    }
    
    fileprivate func getWaterWidth() -> CGFloat {
        var width: CGFloat = 0
        if layoutDirection == .vertical {
            width = collectionView!.bounds.size.width - sectionInset.left - sectionInset.right
        } else {
            width = collectionView!.bounds.size.height - sectionInset.top - sectionInset.bottom
        }
        let spaceWaterCount = CGFloat(waterCount - 1)
        return floor((width - (spaceWaterCount*self.minimumWaterSpacing)) / CGFloat(self.waterCount))
    }
    
    fileprivate func layoutHeaders(totalSize size: inout CGSize, attributes: inout UICollectionViewLayoutAttributes, for section: Int) {
        
        var headerSize: CGSize
        
        if let hsize = delegate?.collectionView?(collectionView!, layout: self, sizeForHeaderInSection: section) {
            headerSize = hsize
        } else {
            headerSize = self.headerSize
        }
        
        let h = layoutDirection == .horizontal && headerSize.width > 0
        let v = layoutDirection == .vertical && headerSize.height > 0
        if h || v {
            attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YJCollectionSectionHeader, with: IndexPath(item: 0, section: section))
            
            let x = h ? size.width : 0, y = v ? size.height : 0
            if h {
                headerSize.height = collectionView!.bounds.size.height
            } else {
                headerSize.width = collectionView!.bounds.size.width
            }
            
            attributes.frame = CGRect(x: x, y: y, width: headerSize.width, height: headerSize.height)
            headerAttributes[section] = attributes
            allItemAttributes.append(attributes)
            
            size = CGSize(width: attributes.frame.maxX, height: attributes.frame.maxY)
        }
        
        size.height += sectionInset.top
        size.width += sectionInset.left
        
        for idx in 0..<waterCount {
            itemSizes[idx] = size
        }
    }
    
    fileprivate func layoutFooters(totalSize size: inout CGSize, attributes: inout UICollectionViewLayoutAttributes, minimumWaterSpacing: CGFloat, minimumItemSpacing: CGFloat, for section: Int) {
        
        var footerSize: CGSize
        let longestIdx = longestIndex()
        
        if layoutDirection == .horizontal {
            size.width = itemSizes[longestIdx].width + sectionInset.right
            size.height = collectionView!.bounds.size.height
        }else {
            size.height = itemSizes[longestIdx].height + sectionInset.bottom
            size.width = collectionView!.bounds.size.width
        }
        
        if let fsize = delegate?.collectionView?(collectionView!, layout: self, sizeForFooterInSection: section) {
            footerSize = fsize
        } else {
            footerSize = self.footerSize
        }
        
        let h = layoutDirection == .horizontal && footerSize.width > 0
        let v = layoutDirection == .vertical && footerSize.height > 0
        
        if h || v {
            attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: YJCollectionSectionFooter, with: IndexPath(item: 0, section: section))
            
            let x = h ? size.width : 0, y = v ? size.height : 0
            if h {
                footerSize.height = collectionView!.bounds.size.height
            } else {
                footerSize.width = collectionView!.bounds.size.width
            }
            
            attributes.frame = CGRect(x: x, y: y, width: footerSize.width, height: footerSize.height)
            footerAttributes[section] = attributes
            allItemAttributes.append(attributes)
            
            size = CGSize(width: attributes.frame.maxX, height: attributes.frame.maxY)
        }
        
        for idx in 0..<waterCount {
            itemSizes[idx] = size
        }
    }
    
    fileprivate func layoutItems(totalSize size: inout CGSize, attributes: inout UICollectionViewLayoutAttributes, minimumWaterSpacing: CGFloat, minimumItemSpacing: CGFloat, for section: Int) {
        
        let itemCount = collectionView!.numberOfItems(inSection: section)
        var itemAttributes = [UICollectionViewLayoutAttributes]()
        
        for idx in 0..<itemCount {
            let indexPath = IndexPath(item: idx, section: section)
            
            let index = shortestIndex()
            
            let xOffset = layoutDirection == .vertical ? sectionInset.left + (waterWidth + minimumWaterSpacing) * CGFloat(index) : itemSizes[index].width
            let yOffset = layoutDirection == .vertical ? itemSizes[index].height : sectionInset.top + (waterWidth + minimumWaterSpacing) * CGFloat(index)
			
			var itemSize: CGSize?
			if #available(iOS 9.0, *) {
				if enableMove && longGes.state == .changed {
					if itemLayoutDatas == nil {
						itemLayoutDatas = moveAction?.itemLayoutDatas(layout: self)
					}
					guard let _ = itemLayoutDatas else { return }
					itemSize = itemLayoutDatas?[indexPath.item].size
				} else {
					itemSize = delegate?.collectionView(collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
				}
			} else {
				itemSize = delegate?.collectionView(collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
			}
			
            
            var itemLength: CGFloat = 0.0
			
            if itemSize! > CGSize.zero {
                itemLength = layoutDirection == .vertical ? (itemSize!.height * waterWidth/itemSize!.width) : (itemSize!.width * waterWidth/itemSize!.height)
            }
			
            attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: layoutDirection == .vertical ? waterWidth : itemLength, height: layoutDirection == .vertical ? itemLength : waterWidth)
            
            itemAttributes.append(attributes)
            allItemAttributes.append(attributes)
            
            itemSizes[index] = CGSize(width: attributes.frame.maxX + minimumItemSpacing, height: attributes.frame.maxY + minimumItemSpacing)
        }
        sectionItemAttributes.append(itemAttributes)
    }
    
    fileprivate func reset() {
        headerAttributes.removeAll(keepingCapacity: true)
        footerAttributes.removeAll(keepingCapacity: true)
        unionRects.removeAll(keepingCapacity: true)
        itemSizes.removeAll(keepingCapacity: true)
        allItemAttributes.removeAll(keepingCapacity: true)
        sectionItemAttributes.removeAll(keepingCapacity: true)
		
		if #available(iOS 9.0, *) {
			if let enable = moveAction?.enableMoveItem(self) {
				enableMove = enable
			}
		}
    }
	
	@available(iOS 9.0, *)
	@objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
		
		switch(gesture.state) {
			
		case .began:
			guard let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
				break
			}
			if let datas = moveAction?.itemLayoutDatas(layout: self) {
				itemLayoutDatas = datas
				collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
			}
		case .changed:
			collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
		case .ended:
			collectionView?.endInteractiveMovement()
			itemLayoutDatas = nil
		default:
			collectionView?.cancelInteractiveMovement()
			itemLayoutDatas = nil
		}
	}
}


// MARK: - move
extension YJWaterFlowLayout {
	@available(iOS 9.0, *)
	open override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
		
		let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
		
		//同一分区，不同item
		if previousIndexPaths.first!.item != targetIndexPaths.first!.item {
			if let _ = itemLayoutDatas {
				moveItem(&itemLayoutDatas!, moveItemAt: previousIndexPaths.first!, to: targetIndexPaths.first!)
			}
		}
		
		return context
	}
	
	@available(iOS 9.0, *)
	open override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
		let attr = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
		attr.alpha = 0.75
		
		return attr
	}
}


