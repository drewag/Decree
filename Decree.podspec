Pod::Spec.new do |spec|
  spec.name          = 'Decree'
  spec.version       = '2.0.0'
  spec.license       = { :type => 'MIT', :file => "LICENSE" }
  spec.homepage      = 'https://github.com/drewag/Decree'
  spec.authors       = { 'Andrew J. Wagner' => 'https://drewag.me' }
  spec.summary       = 'Framework for making Declarative HTTP Requests'
  spec.source        = { :git => 'https://github.com/drewag/Decree.git', :tag => spec.version.to_s }
  spec.swift_version = '5.0.1'

  spec.ios.deployment_target  = '9.0'
  spec.osx.deployment_target  = '10.11'
  spec.tvos.deployment_target  = '9.0'

  spec.source_files       = 'Sources/Decree/**/*.swift'

  spec.dependency 'XMLCoder', '~> 0.7.0'
end
