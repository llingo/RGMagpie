#
# Be sure to run `pod lib lint RGMagpie.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RGMagpie'
  s.version          = '0.5.1'
  s.summary          = 'RGMagpie is an asynchronous image processing library.'
  s.description      = <<-DESC
RGMagpie is a simple tool for processing asynchronous image
                       DESC
  s.homepage         = 'https://github.com/llingo/RGMagpie'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'llingo' => 'llingo@kakao.com' }
  s.source           = { :git => 'https://github.com/llingo/RGMagpie.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.source_files = 'RGMagpie/Classes/**/*'
  s.frameworks = 'UIKit'
  s.swift_versions = '5.4'
end
