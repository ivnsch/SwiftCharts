Pod::Spec.new do |s|
  s.name = "SwiftCharts"
  s.version = "0.6"
  s.summary = "Easy to use and highly customizable charts library for iOS"
  s.homepage = "https://github.com/i-schuetz/SwiftCharts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = { "Ivan Schuetz" => "ivanschuetz@gmail.com"} 
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => "https://github.com/i-schuetz/SwiftCharts.git", :tag => '0.6'}
  s.source_files = 'SwiftCharts/*.swift', 'SwiftCharts/**/*.swift'
  s.frameworks = "Foundation", "UIKit", "CoreGraphics"
end
