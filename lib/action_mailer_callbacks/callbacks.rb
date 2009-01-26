module ActionMailerCallbacks::Callbacks

  class CallbackChain < ActiveSupport::Callbacks::CallbackChain; end

  class Callback < ActiveSupport::Callbacks::Callback
    def initialize(callable, options = {})
      @method, @options = callable, options.symbolize_keys

      normalize_option :only
      normalize_option :except

      @method = @method.to_sym if @method.is_a?(String) # treat a string like a symbol, so the eval String logic from ActiveSupport::Callbacks::Callback is not used
    end

    private
    def should_run_callback?(*arguments)
      mailer_method_name = arguments.first[:mailer_method_name]
      return false if options[:only] && !options[:only].include?(mailer_method_name.to_sym)
      return false if options[:except] && options[:except].include?(mailer_method_name.to_sym)
      return true
    end

    def evaluate_method(method, *arguments)
      target = arguments.first[:target]
      mail = arguments.first[:mail]

      case method
      when Symbol
        target.send(method, mail)
      when Proc, Method
        method.call(mail)
      end
    end

    def normalize_option(option_type)
      return unless options[option_type]

      # build a an array of all method names as symbols
      options[option_type] = [].push(*options[option_type]).inject([]) do |method_names, method_name|
        method_names << method_name.to_sym unless method_name.blank?
        method_names
      end
    end
  end

end