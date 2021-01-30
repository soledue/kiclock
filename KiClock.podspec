
Pod::Spec.new do |s|

  s.name         = "KiClock"
  s.version      = "1.0.0"
  s.summary      = "A siple analogic clock"

  s.homepage         = 'https://github.com/soledue/kiclock.git'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ivailo Kanev' => 'ivo@kanev.it' }
  s.source           = { :git => 'https://github.com/soledue/kiclock.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.swift_versions     = ['4.2','5.0','5.1','5.2']
  s.requires_arc       = true

  s.source_files       = 'Sources/*.swift'
  s.ios.framework      = 'UIKit'

end
