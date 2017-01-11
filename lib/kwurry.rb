require "kwurry/version"

module Kwurry
  def kwurry
    # index keyword names by keyword type
    ki = parameters.reduce(Hash.new { |h, k| h[k] = [] }) { |h, (type, name)| h[type] << name; h }
    keyreqs = ki[:keyreq]
    keyopts = ki[:key]
    keyrest = ki[:keyrest].any?

    # accepts keyword names of all passed arguments
    # raises error if invalid keyword names supplied
    # returns true if all required keyword names supplied
    # returns false otherwise (indicates partially-applied lambda should be returned)
    apply = ->(keys) {
      if !keyrest
        invalid_keys = (keys - (keyreqs + keyopts))
        raise ArgumentError.new("unknown keyword: #{invalid_keys}") if invalid_keys.any?
      end
      (keyreqs - keys).empty?
    }

    # accepts any previously passed kwargs
    # returns a lambda that accepts any kwargs which ...
    # * returns result of original lambda if should apply
    # * otherwise invokes factory to return partially-applied curried lambda
    factory = ->(**applied_kwargs) {
      ->(**kw) {
        kwargs = applied_kwargs.merge(kw)
        return self.(**kwargs) if apply.(kwargs.keys)
        factory.(**kwargs)
      }
    }

    # factory and apply are defined in this closure so they can access
    # keyreqs, keyopts, keyrest
    # as well as self (original lambda) to eventually invoke it

    # inovke factory (with no args) to curry the lambda initially
    # return the curried lambda it returns
    factory.()
  end

  refine Proc do
    define_method :kwurry, Kwurry.instance_method(:kwurry)
  end
end
