//
//  ViewController.swift
//  WaterFlowCollectionView
//
//  Created by ddn on 16/9/20.
//  Copyright © 2016年 张永俊. All rights reserved.
//

import UIKit
import YJWaterFlowLayout

class ViewController: UIViewController {
    
    fileprivate var collectionView: UICollectionView?
    var datas: [Int] = [Int]()
    
    @IBAction func switchHeader(_ sender: UIButton) {
        let layout = collectionView!.collectionViewLayout as! YJWaterFlowLayout
        if layout.headerSize == CGSize.zero {
            layout.headerSize = CGSize(width: 50, height: 50)
        } else {
            layout.headerSize = CGSize.zero
        }
    }
    
    
    @IBAction func switchFooter(_ sender: UIButton) {
        let layout = collectionView!.collectionViewLayout as! YJWaterFlowLayout
        if layout.footerSize == CGSize.zero {
            layout.footerSize = CGSize(width: 50, height: 50)
        } else {
            layout.footerSize = CGSize.zero
        }
    }
    
    
    @IBAction func switchDirection(_ sender: UIButton) {
        let layout = collectionView!.collectionViewLayout as! YJWaterFlowLayout
        if layout.layoutDirection == .vertical {
            collectionView?.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300)
            layout.layoutDirection = .horizontal
        } else {
            collectionView?.bounds = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height * 0.7)
            layout.layoutDirection = .vertical
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		for _ in 0...19 {
			let height = Int(arc4random_uniform((UInt32(100)))) + 40
			datas.append(height)
		}
		
        let layout = YJWaterFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 26, left: 8, bottom: 8, right: 8)
        layout.headerSize = CGSize.zero
        layout.footerSize = CGSize.zero
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
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: datas[indexPath.item])
    }
}


extension ViewController: YJWaterLayoutMovable {
	func enableMoveItem(_ layout: YJWaterFlowLayout) -> Bool {
		return true
	}
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WaterFlowCell
        cell.textLabel.text = "\(datas[indexPath.item]): \(indexPath.item)"
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

