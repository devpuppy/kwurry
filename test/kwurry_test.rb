require 'test_helper'

class KwurryTest < Minitest::Test

  using Kwurry

  def test_that_it_has_a_version_number
    refute_nil ::Kwurry::VERSION
  end

  def f
    @f ||= lambda { |a:, b:, c: nil, **xs| {a: a, b: b, c: c}.merge(xs) }
  end

  def test_that_lambda_has_kwurry
    # assert_respond_to f, :kwurry # respond_to? not compatible with refinements
    f.kwurry
  rescue NoMethodError => e
    flunk e
  end

  def test_that_kwurry_returns_new_lambda
    g = f.kwurry
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
    refute_same f, g
  end

  def test_that_partial_application_returns_lambda
    g = f.kwurry.(a: 1)
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
  end

  def test_that_full_application_returns_result
    result = f.(a: 1, b: 2)
    assert_equal result, f.kwurry.(a: 1).(b: 2)
  end

  def test_that_partial_application_of_keyreqs_returns_lambda
    g = f.kwurry.(a: 1).(c: 3)
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
  end

  def test_that_full_application_returns_result_eventually
    result = f.(a: 1, b: 2, c: 3)
    assert_equal result, f.kwurry.(a: 1).(c: 3).(b: 2)
  end

  def test_that_partial_application_continues_indefinitely
    g = f.kwurry.(a: 1).(x: -1).(y: -2).(z: -3)
    assert_instance_of Proc, g
    assert g.lambda?, 'is not lambda'
  end

  def test_that_catches_invalid_keys_immediately
    g = ->(a:, b:) { a + b }.kwurry
    assert_raises ArgumentError do
      g.(c: 3)
    end
  end

  # Ruby 3.x and 4.x keyword argument compatibility regressions.
  def test_required_keywords_can_arrive_in_reverse_order
    fn = ->(a:, b:) { [a, b] }
    assert_equal [1, 2], fn.kwurry.(b: 2).(a: 1)
  end

  def test_optional_keyword_can_arrive_before_required_keywords
    fn = ->(a:, b: 10) { [a, b] }
    assert_equal [1, 3], fn.kwurry.(b: 3).(a: 1)
  end

  def test_later_application_overrides_an_earlier_keyword
    fn = ->(a:, b:) { [a, b] }
    assert_equal [9, 2], fn.kwurry.(a: 1).(a: 9).(b: 2)
  end

  def test_unknown_keyword_is_rejected_without_keyword_rest
    fn = ->(a:, b: nil) { [a, b] }
    assert_raises(ArgumentError) { fn.kwurry.(a: 1, extra: 2) }
  end

  def test_keyword_rest_accepts_additional_keywords
    fn = ->(a:, **extras) { [a, extras] }
    assert_equal [1, {extra: 2}], fn.kwurry.(extra: 2).(a: 1)
  end

  def test_empty_keyword_application_keeps_required_keywords_pending
    fn = ->(a:) { a }
    partial = fn.kwurry.(**{})
    assert_instance_of Proc, partial
    assert_equal 7, partial.(a: 7)
  end

  def test_positional_hash_is_not_implicitly_converted_to_keywords
    fn = ->(a:) { a }
    assert_raises(ArgumentError) { fn.kwurry.({a: 1}) }
  end
end
