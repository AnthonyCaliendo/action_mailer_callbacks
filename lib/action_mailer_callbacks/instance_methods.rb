module ActionMailerCallbacks::InstanceMethods

  def self.included(base)
    base.alias_method_chain :create_mail, :method_stored
    base.alias_method_chain :create!, :method_stored
    base.alias_method_chain :deliver!, :callbacks
  end

  def create_mail_with_method_stored
    mail = create_mail_without_method_stored
    mail.instance_variable_set '@method_name', @method_name
    mail
  end

  def create_with_method_stored!(method_name, *parameters)
    @method_name = method_name
    create_without_method_stored!(method_name, *parameters)
  end
  
  def deliver_with_callbacks!(mail = @mail)
    self.class.callback_chain_halted = false
    if invoke_delivery_callbacks(:before, mail)
      deliver_without_callbacks!
      invoke_delivery_callbacks(:after, mail)
    end
  end

  private
  def invoke_delivery_callbacks(type, mail)
    callbacks = self.class.class_variable_defined?("@@#{type}_deliver_callbacks") ? self.class.send(:class_variable_get, "@@#{type}_deliver_callbacks") : {}
    method = mail.instance_variable_get '@method_name'

    callbacks.each do |callable, options|
      break if callback_chain_halted

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

    return !callback_chain_halted
  end
  
end