require File.dirname(__FILE__) + '/../test_helper'

class ActionMailerCallbacksTest < Test::Unit::TestCase
  class TestMailer < ActionMailer::Base
    cattr_accessor :befores, :afters
    
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
  
end
