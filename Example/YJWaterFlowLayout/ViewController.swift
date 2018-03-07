//
//  ViewController.swift
//  WaterFlowCollectionView
//
//  Created by ddn on 16/9/20.
//  Copyright © 2016年 张永俊. All rights reserved.
//

import UIKit
import YJWaterFlowLayout

struct ItemLayout: YJWaterLayoutModelable {
	var size: CGSize
}

class ViewController: UIViewController {
    fileprivate var collectionView: UICollectionView?
    var datas: [YJWaterLayoutModelable] = [YJWaterLayoutModelable]()
    
    @IBAction func switchHeader(_ sender: UIButton) {
        let layout = collectionView!.collectionViewLayout as! YJWaterFlowLayout
        if layout.headerSize == CGSize.zero {
            if layout.layoutDirection == .vertical {
                layout.headerSize = CGSize(width: collectionView!.bounds.width, height: 50)
            } else {
                layout.headerSize = CGSize(width: 50, height: collectionView!.bounds.height)
            }
        } else {
            layout.headerSize = CGSize.zero
        }
        layout.invalidateLayout()
    }
    
    
    @IBAction func switchFooter(_ sender: UIButton) {
        let layout = collectionView!.collectionViewLayout as! YJWaterFlowLayout
        if layout.footerSize == CGSize.zero {
            if layout.layoutDirection == .vertical {
                layout.footerSize = CGSize(width: collectionView!.bounds.width, height: 50)
            } else {
                layout.footerSize = CGSize(width: 50, height: collectionView!.bounds.height)
            }
        } else {
            layout.footerSize = CGSize.zero
        }
        layout.invalidateLayout()
    }
    
    
    @IBAction func switchDirection(_ sender: UIButton) {
        let layout = collectionView!.collectionViewLayout as! YJWaterFlowLayout
        if layout.layoutDirection == .vertical {
            collectionView?.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300)
            layout.layoutDirection = .horizontal
            if layout.headerSize != CGSize.zero {
                layout.headerSize = CGSize(width: 50, height: collectionView!.bounds.height)
            }
            if layout.footerSize != CGSize.zero {
                layout.footerSize = CGSize(width: 50, height: collectionView!.bounds.height)
            }
        } else {
            collectionView?.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height * 0.7)
            layout.layoutDirection = .vertical
            if layout.headerSize != CGSize.zero {
                layout.headerSize = CGSize(width: collectionView!.bounds.width, height: 50)
            }
            if layout.footerSize != CGSize.zero {
                layout.footerSize = CGSize(width: collectionView!.bounds.width, height: 50)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		for _ in 0...19 {
			let height = Int(arc4random_uniform((UInt32(100)))) + 40
			
			datas.append(ItemLayout(size: CGSize(width: 100, height: height)))
		}
		
        let layout = YJWaterFlowLayout()
        layout.delegate = self
        layout.moveAction = self
		
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 24, width: view.bounds.size.width, height: view.bounds.size.height * 0.7), collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.green
        
        collectionView?.register(UINib.init(nibName: "WaterFlowCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView?.register(TestHeader.self, forSupplementaryViewOfKind: YJCollectionSectionHeader, withReuseIdentifier: "header")
        collectionView?.register(TestHeader.self, forSupplementaryViewOfKind: YJCollectionSectionFooter, withReuseIdentifier: "footer")
        collectionView?.dataSource = self
        collectionView?.delegate = self
		
        view.addSubview(collectionView!)
		
		
    }
}

extension ViewController: YJWaterLayoutDelegate {
    
	func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: YJWaterFlowLayout,
	                     ratioForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: 100, height: datas[indexPath.item].size.height)
        case 1, 2:
            return CGSize(width: 100, height: 100)
        case 3:
            let realWidth = collectionView.bounds.width - 200
            switch indexPath.item {
            case 0:
                return CGSize(width: 200, height: 200)
            case 1:
                return CGSize(width: realWidth, height: 150)
            case 2:
                return CGSize(width: realWidth, height: 50)
            default:
                return CGSize(width: 100, height: 100)
            }
        default:
            return CGSize(width: 100, height: 100)
        }
	}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout, waterCountForSection section: Int) -> Int {
        switch section {
        case 0, 1, 3:
            return 2
        case 2:
            return 3
        case 4:
            return 1
        default:
            return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout, waterWidthForSection section: Int, at index: Int) -> CGFloat {
        switch section {
        case 3:
            return index == 0 ? 200 : collectionView.bounds.width - 200
        default:
            return YJCollectionAutoCGFloat
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                         minimumWaterSpacingForSection section: Int) -> CGFloat {
        return section == 3 ? 0 : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout, minimumItemSpacingForSection section: Int) -> CGFloat {
        return section == 3 ? 0 : 10
    }
}


extension ViewController: YJWaterLayoutMovable {
	func enableMoveItem(_ layout: YJWaterFlowLayout) -> Bool {
		return true
	}
	func itemLayoutDatas (layout collectionViewLayout: YJWaterFlowLayout) -> [YJWaterLayoutModelable] {
		return datas
	}
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return datas.count
        case 1:
            return 4
        case 2:
            return 9
        case 3:
            return 3
        default:
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WaterFlowCell
        cell.textLabel.text = "section:\(indexPath.section)-item:\(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		if #available(iOS 9.0, *) {
			(collectionView.collectionViewLayout as! YJWaterFlowLayout).moveItem(&datas, moveItemAt: sourceIndexPath, to: destinationIndexPath)
		}
    }
	
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == YJCollectionSectionHeader {
            //复用header
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: YJCollectionSectionHeader, withReuseIdentifier: "header", for: indexPath)
            header.backgroundColor = UIColor.red
            return header
        }else {
            //复用footer
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: YJCollectionSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            footer.backgroundColor = UIColor.blue
            return footer
        }
    }
}

class TestHeader: UICollectionReusableView {
    
}

extension ViewController: UICollectionViewDelegate {
    
}

