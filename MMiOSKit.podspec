Pod::Spec.new do |spec|
  spec.name                     = "MMiOSKit"
  spec.version                  = "1.0.0"
  spec.summary                  = "MMiOSKit"
  spec.platform                 = :ios
  spec.license                  = { :type => 'Apache', :file => 'LICENSE' }
  spec.ios.deployment_target 	  = "7.0"
  spec.authors                  = { "Yang Zexin" => "yangzexin27@gmail.com" }
  spec.homepage                 = "https://github.com/yangzexin/MMiOSKit"
  spec.source                   = { :git => "#{spec.homepage}.git", :branch => "master" }
  spec.requires_arc             = true
  spec.source_files = "MMiOSKit/*.{h,m}"
  spec.prefix_header_contents = "#import <objc/runtime.h>"
  
  spec.dependency "SFFoundation"
  spec.dependency "SFiOSKit"
end
