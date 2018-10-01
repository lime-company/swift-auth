Pod::Spec.new do |s|
  s.name = 'LimeAuth'
  s.version = '%DEPLOY_VERSION%'
  # Metadata
  s.license = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.summary = 'High level PowerAuth based authentication library written in swift'
  s.homepage = 'https://github.com/lime-company/swift-lime-auth'
  s.social_media_url = 'https://twitter.com/lime_company'
  s.author = { 'Lime - HighTech Solutions s.r.o.' => 'support@lime-company.eu' }
  s.source = { :git => 'https://github.com/lime-company/swift-lime-auth.git', :tag => s.version }
  # Deployment targets
  s.swift_version = '4.2'
  s.ios.deployment_target = '9.0'
  
  # Sources
  s.default_subspec = 'Core'
  
  # 'Core' subspec
  s.subspec 'Core' do |sub|
    sub.source_files = 'Source/Core/**/*.swift'
    sub.dependency 'LimeCore', '~> 1.1'
    sub.dependency 'PowerAuth2'
  end
  
  # 'UI' subspec
  s.subspec 'UI' do |sub|
    sub.source_files = 'Source/UI/**/*.swift'
    sub.dependency 'LimeAuth/Core'
  end
  
  # 'UIResources' subspec
  s.subspec 'UIResources' do |sub|
    sub.source_files = 'Source/UIResources/**/*.swift'
    sub.resources = [ 'Source/UIResources/**/*.storyboard', 'Source/UIResources/*.xcassets' ]
    sub.dependency 'LimeAuth/UI'
  end

  # 'UIResources_Images' subspec
  s.subspec 'UIResources_Images' do |sub|
    sub.resources = [ 'Source/UIResources_Images/*.xcassets' ]
    sub.dependency 'LimeAuth/UIResources'
  end

  # 'UIResources_Illustrations' subspec
  s.subspec 'UIResources_Illustrations' do |sub|
    sub.resources = [ 'Source/UIResources_Illustrations/*.xcassets' ]
    sub.dependency 'LimeAuth/UIResources'
  end

  # 'UIResources_Localization' subspec
  s.subspec 'UIResources_Localization' do |sub|
    sub.resources = [ 'Source/UIResources_Localization/*.lproj' ]
    sub.dependency 'LimeAuth/UIResources'
  end

end
