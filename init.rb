require File.join(File.dirname(__FILE__), "lib", "paperclip")
ActiveRecord::Base.extend( Thoughtbot::Paperclip::ClassMethods )