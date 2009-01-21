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
  
  should 'invoke before with block' do
    TestMailer.deliver_always
    assert_true TestMailer.befores.include?(:before_block)
  end
    
  should 'invoke before with symbol' do
    TestMailer.deliver_always
    assert_true TestMailer.befores.include?(:before_symbol)
  end
    
  should 'invoke before with string' do
    TestMailer.deliver_always
    assert_true TestMailer.befores.include?(:before_string)
  end
    
  should 'invoke before when in only option' do
    TestMailer.deliver_in_only
    assert_true TestMailer.befores.include?(:before_only)
  end
    
  should 'invoke before when not in except option' do
    TestMailer.deliver_not_in_except
    assert_true TestMailer.befores.include?(:before_except)
  end
    
  should 'not invoke before when not in only option' do
    TestMailer.deliver_not_in_only
    assert_false TestMailer.befores.include?(:before_only)
  end
    
  should 'not invoke before when in except option' do
    TestMailer.deliver_in_except
    assert_false TestMailer.befores.include?(:before_except)
  end
  
  should 'invoke after with block' do
    TestMailer.deliver_always
    assert_true TestMailer.afters.include?(:after_block)
  end
    
  should 'invoke after with symbol' do
    TestMailer.deliver_always
    assert_true TestMailer.afters.include?(:after_symbol)
  end
    
  should 'invoke after with string' do
    TestMailer.deliver_always
    assert_true TestMailer.afters.include?(:after_string)
  end
    
  should 'invoke after when in only option' do
    TestMailer.deliver_in_only
    assert_true TestMailer.afters.include?(:after_only)
  end
    
  should 'invoke after when not in except option' do
    TestMailer.deliver_not_in_except
    assert_true TestMailer.afters.include?(:after_except)
  end
    
  should 'not invoke after when not in only option' do
    TestMailer.deliver_not_in_only
    assert_false TestMailer.afters.include?(:after_only)
  end
    
  should 'not invoke after when in except option' do
    TestMailer.deliver_in_except
    assert_false TestMailer.afters.include?(:after_except)
  end
  
end
