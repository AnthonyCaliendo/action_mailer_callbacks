class ActionMailer::Base
  def self.before_deliver(*args, &block)
    delivery_callback :before, *args, &block
  end
  
  def self.after_deliver(*args, &block)
    delivery_callback :after, *args, &block
  end
  
  def self.delivery_callback(type, *args, &block)
    args = args.dup
    
    method = args.first
    method = nil if method.is_a?(Hash)
    
    options = args.pop
    options = {} unless options.is_a?(Hash)
    
    callable = block || method
    raise 'Specify a block or method to invoke in "before_deliver"' unless callable
    
    callbacks = class_variable_defined?("@@#{type}_deliver_callbacks") ? class_variable_get("@@#{type}_deliver_callbacks") : ActiveSupport::OrderedHash.new
    callbacks[callable] = options.symbolize_keys
    class_variable_set("@@#{type}_deliver_callbacks", callbacks)
  end
  
  private
  def create_mail_with_method_stored
    mail = create_mail_without_method_stored
    mail.instance_variable_set '@method_name', @method_name
    mail
  end
  alias_method_chain :create_mail, :method_stored
  
  def create_with_method_stored!(method_name, *parameters)
    @method_name = method_name
    create_without_method_stored!(method_name, *parameters)
  end
  alias_method_chain :create!, :method_stored
  
  def deliver_with_callbacks!(mail = @mail)
    invoke_delivery_callbacks(:before, mail)
    deliver_without_callbacks!
    invoke_delivery_callbacks(:after, mail)
  end
  alias_method_chain :deliver!, :callbacks

  def invoke_delivery_callbacks(type, mail)
    callbacks = self.class.class_variable_defined?("@@#{type}_deliver_callbacks") ? self.class.send(:class_variable_get, "@@#{type}_deliver_callbacks") : {}
    method = mail.instance_variable_get '@method_name'
    
    callbacks.each do |callable, options|
      only = [].push(*options[:only]) if options[:only] && method
      next if only && !(only.include?(method.to_s) || only.include?(method.to_sym))
      
      except = [].push(*options[:except]) if options[:except] && method
      next if except && (except.include?(method.to_s) || except.include?(method.to_sym))
      
      if callable.is_a? Proc
        callable.call(mail)
      else
        send(callable, mail)
      end
    end
  end
  
end
