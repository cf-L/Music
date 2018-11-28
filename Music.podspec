Pod::Spec.new do |s|
  s.name             = 'Music'
  s.version          = '0.1.1'
  s.summary          = 'A music client for playing SoundCloud and Youtube music.'

  s.description      = <<-DESC
'A music client for playing SoundCloud and Youtube music.'
                       DESC

  s.homepage         = 'https://github.com/cf-L/Music'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cf-L' => 'linchangfeng@live.com' }
  s.source           = { :git => 'https://github.com/cf-L/Music.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Music/Classes/**/*'
  
  s.dependency 'Common', '~> 4.0.14'
  s.dependency 'Alamofire', '~> 4.7.3'
  s.dependency 'XCDYouTubeKit', '~> 2.7.1'
  s.dependency 'RealmSwift', '~> 3.11.2'
  s.dependency 'SDWebImage', '~> 4.4.2'
end
