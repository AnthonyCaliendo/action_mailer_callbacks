module ActionMailerCallbacks::ClassMethods

  def self.extended(base)
    base.cattr_accessor(:callback_chain_halted)
  end

  def before_deliver(*args, &block)
    delivery_callback :before, *args, &block
  end

  def after_deliver(*args, &block)
    delivery_callback :after, *args, &block
  end

  def halt_callback_chain
    self.callback_chain_halted = true
  end

  private
  def delivery_callback(type, *args, &block)
    args = args.dup

    method = args.first
    method = nil if method.is_a?(Hash)

    options = args.pop
    options = {} unless options.is_a?(Hash)

    callable = block || method
    raise 'Specify a block or method to invoke in "before_deliver"' unless callable

    callbacks = class_variable_defined?("@@#{type}_deliver_callbacks") ? class_variable_get("@@#{type}_deliver_callbacks") : ActionMailerCallbacks::Callbacks::CallbackChain.new
    callbacks << ActionMailerCallbacks::Callbacks::Callback.new(callable, options)
    class_variable_set("@@#{type}_deliver_callbacks", callbacks)
  end
  
end