Pod::Spec.new do |s|
  s.name             = 'Dummy'
  s.version          = '0.0.1'
  s.summary          = 'Dummy pod to bypass CocoaPods empty dependency check'
  s.homepage         = 'https://github.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Author' => 'author@example.com' }
  s.source           = { :git => 'https://github.com/dummy/dummy.git', :tag => s.version.to_s }
  s.source_files     = 'Dummy/**/*'
  s.ios.deployment_target = '13.0'
end
