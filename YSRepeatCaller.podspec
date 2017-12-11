Pod::Spec.new do |s|
  s.name         = "YSRepeatCaller"
  s.version      = "1.0.1"
  s.summary      = "A Class Repeat Call Method"
  s.homepage     = "https://github.com/iSylvan/YSRepeatCaller"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "sylvan" => "yanshan.cool@gmial.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/iSylvan/YSRepeatCaller.git", :tag => s.version }
  s.source_files  = "YSRepeatCaller"
  s.requires_arc = true
end
