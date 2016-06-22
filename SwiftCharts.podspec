Pod::Spec.new do |s|
  s.name = "GrafitiSwiftCharts"
  s.version = "0.4"
  s.summary = "extensible, flexible charts library for iOS with extensions for Grafiti.io"
  s.homepage = "http://grafiti.io"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = { "Ivan Schuetz" => "ivanschuetz@gmail.com", "Grafiti" => "info@grafiti.io" } 
  s.ios.deployment_target = "9.0"
  s.source = { :git => "https://github.com/grafiti-io/SwiftCharts.git", :tag => '0.4' }
  s.source_files = 'SwiftCharts/*.swift', 'SwiftCharts/**/*.swift'
  s.frameworks = "Foundation", "UIKit", "CoreGraphics"
end
