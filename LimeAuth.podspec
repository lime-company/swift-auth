Pod::Spec.new do |s|
  s.name = 'LimeAuth'
  s.version = '0.2.0'
  # Metadata
  s.license = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.summary = 'High level PowerAuth based authentication library written in swift'
  s.homepage = 'https://github.com/lime-company/swift-lime-auth'
  s.social_media_url = 'https://twitter.com/lime_company'
  s.author = { 'Lime - HighTech Solutions s.r.o.' => 'support@lime-company.eu' }
  s.source = { :git => 'https://github.com/lime-company/swift-lime-auth.git', :tag => s.version }
  # Deployment targets
  s.swift_version = '4.0'
  s.ios.deployment_target = '8.0'
  
  # Sources
  s.default_subspec = 'Core'
  
  # 'Core' subspec
  s.subspec 'Core' do |sub|
    sub.source_files = 'Source/Core/**/*.swift'
    sub.dependency 'LimeCore'
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
  
end
