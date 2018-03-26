#
# Be sure to run `pod lib lint YJWaterFlowLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YJWaterFlowLayout'
  s.version          = '0.1.7'
  s.summary          = 'YJWaterFlowLayout'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
YJWaterFlowLayout  横向纵向流布局，不同section可以有不同布局，支持瀑布流，可拖拽item，可添加头视图和脚视图
                       DESC

  s.homepage         = 'https://github.com/Zyj163/YJWaterFlowLayout'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zyj163' => 'zhangyongjun@pj-l.com' }
  s.source           = { :git => 'https://github.com/Zyj163/YJWaterFlowLayout.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YJWaterFlowLayout/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YJWaterFlowLayout' => ['YJWaterFlowLayout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
