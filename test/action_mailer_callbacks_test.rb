require File.expand_path(File.join(File.dirname(__FILE__), '../../../../test/test_helper'))
require 'test/unit'

class ActionMailerCallbacksTest < Test::Unit::TestCase

  # this'd be easier with flexmock... but trying to keep this independent from anything outside of core rails
  class TestMailer < ActionMailer::Base
    cattr_accessor :befores, :afters
    cattr_accessor :before_deliveries, :after_deliveries

    def always; end #no-op
    before_deliver do |mail|
      TestMailer.befores << :before_block
    end
    before_deliver 'before_from_string'
    def before_from_string(mail)
      TestMailer.befores << :before_string
    end
    before_deliver :before_from_symbol
    def before_from_symbol(mail)
      TestMailer.befores << :before_symbol
    end
    after_deliver do |mail|
      TestMailer.afters << :after_block
    end
    after_deliver 'after_from_string'
    def after_from_string(mail)
      TestMailer.afters << :after_string
    end
    after_deliver :after_from_symbol
    def after_from_symbol(mail)
      TestMailer.afters << :after_symbol
    end

    def in_except; end # no-op
    def not_in_except; end #no-op
    before_deliver :except => :in_except do |mail|
      TestMailer.befores << :before_except
    end
    after_deliver :except => :in_except do |mail|
      TestMailer.afters << :after_except
    end

    def in_only; end #no-op
    def not_in_only; end #no-op
    before_deliver :only => :in_only do |mail|
      TestMailer.befores << :before_only
    end
    after_deliver :only => :in_only do |mail|
      TestMailer.afters << :after_only
    end

    def halts; end
    before_deliver :only => :halts do |mail|
      TestMailer.befores << :halts_before
      halt_callback_chain
    end

    after_deliver :only => :halts do |mail|
      TestMailer.afters << :halts_after
      raise 'this should never happen if the chain is halted...'
    end

    # we can test this by checking the deliveries in the before and after callbacks
    def ensure_before_and_after; end
    before_deliver :only => :ensure_before_and_after do |mail|
      TestMailer.befores << :ensure_before
      TestMailer.before_deliveries = ActionMailer::Base.deliveries.dup
    end
    after_deliver :only => :ensure_before_and_after do |mail|
      TestMailer.afters << :ensure_before
      TestMailer.after_deliveries = ActionMailer::Base.deliveries.dup
    end

    def template_path
      "#{RAILS_ROOT}/test/fixtures/test_mailer"
    end

    def render(opts)
      # no-op
    end
  end

  setup do
    TestMailer.befores = []
    TestMailer.afters = []
    TestMailer.before_deliveries = []
    TestMailer.after_deliveries = []
    ActionMailer::Base.deliveries = []
  end

  def test_invoke_before_with_block
    TestMailer.deliver_always
    assert TestMailer.befores.include?(:before_block)
  end

  def test_invoke_before_with_symbol
    TestMailer.deliver_always
    assert TestMailer.befores.include?(:before_symbol)
  end

  def test_invoke_before_with_string
    TestMailer.deliver_always
    assert TestMailer.befores.include?(:before_string)
  end

  def test_invoke_before_when_in_only_option
    TestMailer.deliver_in_only
    assert TestMailer.befores.include?(:before_only)
  end

  def test_invoke_before_when_not_in_except_option
    TestMailer.deliver_not_in_except
    assert TestMailer.befores.include?(:before_except)
  end

  def test_not_invoke_before_when_not_in_only_option
    TestMailer.deliver_not_in_only
    assert !TestMailer.befores.include?(:before_only)
  end

  def not_invoke_before_when_in_except_option
    TestMailer.deliver_in_except
    assert !TestMailer.befores.include?(:before_except)
  end

  def test_invoke_after_with_block
    TestMailer.deliver_always
    assert TestMailer.afters.include?(:after_block)
  end

  def test_invoke_after_with_symbol
    TestMailer.deliver_always
    assert TestMailer.afters.include?(:after_symbol)
  end

  def test_invoke_after_with_string
    TestMailer.deliver_always
    assert TestMailer.afters.include?(:after_string)
  end

  def test_invoke_after_when_in_only_option
    TestMailer.deliver_in_only
    assert TestMailer.afters.include?(:after_only)
  end

  def test_invoke_after_when_not_in_except_option
    TestMailer.deliver_not_in_except
    assert TestMailer.afters.include?(:after_except)
  end

  def test_not_invoke_after_when_not_in_only_option
    TestMailer.deliver_not_in_only
    assert !TestMailer.afters.include?(:after_only)
  end

  def test_not_invoke_after_when_in_except_option
    TestMailer.deliver_in_except
    assert !TestMailer.afters.include?(:after_except)
  end

  def test_should_halt_chain_when_callback_halts
    TestMailer.deliver_halts
    assert TestMailer.befores.include?(:halts_before)
    assert !TestMailer.afters.include?(:halts_after)
  end

  def test_should_not_halt_chain_when_previous_chain_halted
    TestMailer.deliver_halts
    assert !TestMailer.afters.include?(:after_block)

    TestMailer.deliver_always
    assert TestMailer.afters.include?(:after_block)
  end

  def test_ensure_before_filter_called_before_method
    TestMailer.deliver_ensure_before_and_after
    assert TestMailer.before_deliveries.empty?
  end

  def test_ensure_after_filter_called_after_method
    TestMailer.deliver_ensure_before_and_after
    assert !TestMailer.after_deliveries.empty?
  end
end