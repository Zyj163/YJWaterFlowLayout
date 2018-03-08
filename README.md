# YJWaterFlowLayout

[![CI Status](http://img.shields.io/travis/Zyj163/YJWaterFlowLayout.svg?style=flat)](https://travis-ci.org/Zyj163/YJWaterFlowLayout)
[![Version](https://img.shields.io/cocoapods/v/YJWaterFlowLayout.svg?style=flat)](http://cocoapods.org/pods/YJWaterFlowLayout)
[![License](https://img.shields.io/cocoapods/l/YJWaterFlowLayout.svg?style=flat)](http://cocoapods.org/pods/YJWaterFlowLayout)
[![Platform](https://img.shields.io/cocoapods/p/YJWaterFlowLayout.svg?style=flat)](http://cocoapods.org/pods/YJWaterFlowLayout)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
![image](https://github.com/Zyj163/YJWaterFlowLayout/blob/master/Example/YJWaterFlowLayout/movie.gif)
## Requirements

## Installation

YJWaterFlowLayout is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "YJWaterFlowLayout", :git => 'https://github.com/Zyj163/YJWaterFlowLayout.git'
```

## Use
属性：

waterCount

瀑布流的条数，默认为2（优先级低于代理方法中的设置）


minimumWaterSpacing

流间距，默认是10（优先级低于代理方法中的设置）


minimumItemSpacing

同一流中item间距，默认是10（优先级低于代理方法中的设置）


headerSize

section头视图大小，默认没有（优先级低于代理方法中的设置，并且如果是纵向布局，宽度固定为collectionView宽度，横向亦然）


footerSize

section脚视图大小，默认没有（优先级低于代理方法中的设置，并且如果是纵向布局，宽度固定为collectionView宽度，横向亦然）


sectionInset

section内边距，默认没有（优先级低于代理方法中的设置）


layoutDirection

流动方向，默认纵向


unionSize

批量布局个数，可以根据一屏最多可以显示多少个item来设置，默认20


delegate  代理
moveAction 拖拽代理


流条数，可选实现，如果没有实现，使用属性waterCount，返回<=0当作未实现处理
unc collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout, waterCountForSection section: Int) -> Int

根据返回的size计算宽高比，必须实现

func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize


头视图/脚视图大小，可选实现
func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
sizeForHeaderForFooterInSection section: Int, elementKind: String) -> CGSize


返回section中内边距，可选实现，如果没有实现，使用属性sectionInset

func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets


返回section中同一流中item的间距，可选实现，如果没有实现，使用属性minimumItemSpacing

func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
minimumItemSpacingForSection section: NSInteger) -> CGFloat


返回section中流间距，可选实现，如果没有实现，使用属性minimumWaterSpacing

func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
minimumWaterSpacingForSection section: NSInteger) -> CGFloat

流宽度，可选实现，如果没有实现根据contentInsets、minimumWaterSpacing、waterCount计算得来，返回<=0当作未实现处理
func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
waterWidthForSection section: Int, at index: Int) -> CGFloat


修改attributes，background/header/footer/item, kind为nil时为item，可选实现
func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: YJWaterFlowLayout,
relocationForElement kind: String?, inSection section: Int, currentAttributes: UICollectionViewLayoutAttributes)

拖拽需要实现的方法
extension ViewController: YJWaterLayoutMovable {
	func enableMoveItem(_ layout: YJWaterFlowLayout) -> Bool {
		return true
	}
}
func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
	(collectionView.collectionViewLayout as! YJWaterFlowLayout).moveItem(&datas, moveItemAt: sourceIndexPath, to: destinationIndexPath)
}

YJCollectionSectionHeader  header的类型string
YJCollectionSectionFooter  footer的类型string
YJCollectionSectionBackground  background的类型string
以上三种类型用来替换系统提供的UICollectionElementKindSectionHeader等，用法相同，具体可查看demo

YJCollectionAutoInt: Int = 0
YJCollectionAutoFloat: Float = 0
YJCollectionAutoCGFloat: CGFloat = 0
YJCollectionAutoSize: CGSize = CGSize.zero
YJCollectionAutoInsets: UIEdgeInsets = UIEdgeInsets.zero

## Author

Zyj163, zyj194250@163.com

## License

YJWaterFlowLayout is available under the MIT license. See the LICENSE file for more info.
