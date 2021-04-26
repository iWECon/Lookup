Pod::Spec.new do |s|

    s.name = 'Lookup'
    s.version = '1.0.4444'
    s.authors = 'iWw'
    s.homepage = 'https://www.iwecon.cc'
    s.summary = 'Lookup for JSON handler.'
    s.license = { :type => 'MIT' }
    s.ios.deployment_target = '10.0'
    
    s.source = { :git => '.' }
    s.source_files = [
        'Sources/**/*.swift',
    ]
    
    s.cocoapods_version = '>= 1.10.0'
    s.swift_versions = ['5.3']

end
