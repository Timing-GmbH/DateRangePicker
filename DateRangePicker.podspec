Pod::Spec.new do |s|
    s.name                  = 'DateRangePicker'
    s.version               = '1.0'

    s.homepage              = 'https://github.com/MrMage/DateRangePicker'
    s.summary               = 'The best (?) date range picker control for OS X.'
    s.screenshots           = 'https://raw.githubusercontent.com/MrMage/DateRangePicker/master/Screenshots/Popover.png', 'https://raw.githubusercontent.com/MrMage/DateRangePicker/master/Screenshots/ControlVariants.png', 'https://raw.githubusercontent.com/MrMage/DateRangePicker/master/Screenshots/Menu.png'

    s.author                = { 'Daniel Alm' => 'DateRangePicker@danielalm.de' }
    s.license               = { :type => 'ISC (simplified BSD)', :file => 'LICENSE.txt' }
    s.social_media_url      = 'https://twitter.com/daniel_a_a'
    s.platforms             = { :osx => '10.9' }

    s.source_files          = 'DateRangePicker/*.{h,swift}'
    s.module_name           = 'DateRangePicker'
    s.source                = { :git => 'https://github.com/MrMage/DateRangePicker.git', :tag => 'v1.0' }
    s.requires_arc          = true
    s.frameworks            = 'AppKit', 'Foundation'
		
		s.xcconfig = { 'EMBEDDED_CONTENT_CONTAINS_SWIFT' => 'YES' }
end
