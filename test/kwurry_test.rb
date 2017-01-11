require 'test_helper'

class KwurryTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Kwurry::VERSION
  end

  def f
    @f ||= lambda { |a:, b:, c: nil, **xs| {a: a, b: b, c: c}.merge(xs) }
  end


  def test_that_lambda_has_kwurry
    assert f.respond_to?(:kwurry)
  end

  def test_that_kwurry_returns_new_lambda
    g = f.kwurry
    assert g.is_a?(Proc), 'is not Proc'
    assert g.lambda?, 'is not lambda'
    refute_equal f, g, 'is self'
  end

  def test_that_partial_application_returns_lambda
    g = f.kwurry.(a: 1)
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
    refute_equal f, g
  end

  def test_that_full_application_returns_result
    result = f.(a: 1, b: 2)
    assert_equal result, f.kwurry.(a: 1).(b: 2)
  end

  def test_that_partial_application_of_keyreqs_returns_lambda
    g = f.kwurry.(a: 1).(c: 3)
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
    refute_equal f, g
  end

  def test_that_full_application_returns_result_eventually
    result = f.(a: 1, b: 2, c: 3)
    g = f.kwurry.(a: 1).(c: 3).(b: 2)
    assert_equal result, g
  end

  def test_that_partial_application_continues_indefinitely
    g = f.kwurry.(a: 1).(x: -1).(y: -2).(z: -3)
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
    refute_equal f, g
  end

  def test_that_catches_invalid_keys_immediately
    g = ->(a:, b:) { a + b }.kwurry
    assert_raises ArgumentError do
      g.(c: 3)
    end
  end
end
