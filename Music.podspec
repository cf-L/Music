Pod::Spec.new do |s|
  s.name             = 'Music'
  s.version          = '0.1.0'
  s.summary          = 'A music client for playing SoundCloud and Youtube music.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/cf-L/Music'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cf-L' => 'linchangfeng@live.com' }
  s.source           = { :git => 'https://github.com/cf-L/Music.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Music/Classes/**/*'
end
