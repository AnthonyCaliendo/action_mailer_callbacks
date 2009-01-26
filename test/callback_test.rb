require File.expand_path(File.join(File.dirname(__FILE__), '../../../../test/test_helper'))
require 'test/unit'

class ActionMailerCallbacks::CallbackTest < Test::Unit::TestCase

  # remove shoulda dependency
  def assert_contains(collection, item)
    assert collection.include?(item)
  end

  def assert_does_not_contain(collection, item)
    assert !collection.include?(item)
  end

  # this'd be easier with flexmock... but trying to keep this independent from anything outside of core rails
  class MockObject
    attr_accessor :invocations, :mail

    def initialize
      self.invocations = []
    end

    def from_string(mail)
      self.mail = mail
      invocations << :from_string
    end

    def from_symbol(mail)
      self.mail = mail
      invocations << :from_symbol
    end

    def from_method(mail)
      self.mail = mail
      invocations << :from_method
    end

    def some_method; end
  end

  def setup
    super
    @mail = TMail::Mail.new
  end

  def test_should_invoke_proc_in_callback
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method)).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_in_only_option_and_single_option_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :only => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_in_only_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :only => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_in_only_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :only => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_in_only_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :only => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_in_only_option_and_single_option_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'only' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_in_only_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'only' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_in_only_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'only' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_in_only_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'only' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_in_only_option_and_multiple_options_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_in_only_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_in_only_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_in_only_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_in_only_option_and_multiple_options_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_in_only_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_in_only_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_in_only_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_not_in_only_option_and_single_option_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :only => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_not_in_only_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :only => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_not_in_only_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :only => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_not_in_only_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :only => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_not_in_only_option_and_single_option_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'only' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_not_in_only_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'only' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_not_in_only_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'only' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_not_in_only_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'only' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :only => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_not_in_only_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'only' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_not_in_except_option_and_single_option_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :except => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_not_in_except_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :except => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_not_in_except_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :except => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_not_in_except_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :except => :some_method).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_not_in_except_option_and_single_option_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'except' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_not_in_except_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'except' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_not_in_except_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'except' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_not_in_except_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'except' => 'some_method').call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_invoke_proc_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => MockObject.new)

    assert hit_proc
    assert_equal @mail, passed_mail
  end

  def test_should_invoke_method_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_method
    assert_equal @mail, target.mail
  end

  def test_should_invoke_string_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_string
    assert_equal @mail, target.mail
  end

  def test_should_invoke_symbol_in_callback_when_method_is_not_in_except_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_other_method', :mail => @mail, :target => target)

    assert_contains target.invocations, :from_symbol
    assert_equal @mail, target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_in_except_option_and_single_option_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :except => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_in_except_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :except => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_in_except_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :except => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_in_except_option_and_single_option_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :except => :some_method).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_in_except_option_and_single_option_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'except' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_in_except_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'except' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_in_except_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'except' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_in_except_option_and_single_option_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'except' => 'some_method').call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_in_except_option_and_multiple_options_as_symbol
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_in_except_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_in_except_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_in_except_option_and_multiple_options_as_symbol
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, :except => [:another_method, :some_method]).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end

  def test_should_not_invoke_proc_in_callback_when_method_is_in_except_option_and_multiple_options_as_string
    hit_proc = false
    passed_mail = nil
    proc = lambda {|mail|hit_proc = true, passed_mail = mail}

    ActionMailerCallbacks::Callbacks::Callback.new(proc, 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => MockObject.new)

    assert !hit_proc
    assert_nil passed_mail
  end

  def test_should_not_invoke_method_in_callback_when_method_is_in_except_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(target.method(:from_method), 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_method
    assert_nil target.mail
  end

  def test_should_not_invoke_string_in_callback_when_method_is_in_except_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new('from_string', 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_string
    assert_nil target.mail
  end

  def test_should_not_invoke_symbol_in_callback_when_method_is_in_except_option_and_multiple_options_as_string
    target = MockObject.new

    ActionMailerCallbacks::Callbacks::Callback.new(:from_symbol, 'except' => ['another_method', 'some_method']).call(:mailer_method_name => 'some_method', :mail => @mail, :target => target)

    assert_does_not_contain target.invocations, :from_symbol
    assert_nil target.mail
  end
end