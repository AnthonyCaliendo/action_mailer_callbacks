ActionMailer::Base.send :extend, ActionMailerCallbacks::ClassMethods
ActionMailer::Base.send :include, ActionMailerCallbacks::InstanceMethods