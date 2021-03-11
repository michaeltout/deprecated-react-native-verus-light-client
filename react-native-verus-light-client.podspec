require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-verus-light-client"
  s.version      = package["version"]
  s.swift_version= '5.0'
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-verus-light-client
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-verus-light-client"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-verus-light-client.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency 'React-Core'
  s.dependency 'ZcashLightClientKit'
  # ...
  # s.dependency "..."
end

