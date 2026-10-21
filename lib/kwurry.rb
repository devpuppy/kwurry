require "kwurry/version"

module Kwurry
  def kwurry
    # index parameter names by type
    ki = parameters.reduce(Hash.new { |h, k| h[k] = [] }) { |h, (type, name)| h[type] << name; h }
    # Non-lambda Proc#parameters marks positional arguments as optional, even
    # when they have no defaults. Proc#arity captures the minimum instead.
    required_positionals = if lambda?
      ki[:req].length
    else
      positional_arity = arity >= 0 ? arity : -arity - 1
      [positional_arity - ki[:keyreq].length, 0].max
    end
    maximum_positionals = ki[:rest].any? ? nil : ki[:req].length + ki[:opt].length
    keyreqs = ki[:keyreq]
    keyopts = ki[:key]
    keyrest = ki[:keyrest].any?

    # accepts positional arguments and keyword names of all passed arguments
    # raises error if invalid keyword names supplied
    # returns true if all required positional and keyword arguments supplied
    # returns false otherwise (indicates partially-applied lambda should be returned)
    apply = ->(args, keys) {
      if maximum_positionals && args.length > maximum_positionals
        raise ArgumentError.new("wrong number of arguments (given #{args.length}, expected #{required_positionals}..#{maximum_positionals})")
      end
      if !keyrest
        invalid_keys = (keys - (keyreqs + keyopts))
        raise ArgumentError.new("unknown keyword: #{invalid_keys}") if invalid_keys.any?
      end
      args.length >= required_positionals && (keyreqs - keys).empty?
    }

    # accepts any previously passed positional and keyword arguments
    # returns a lambda that accepts positional and keyword arguments which ...
    # * returns result of original lambda if should apply
    # * otherwise invokes factory to return partially-applied curried lambda
    factory = ->(*applied_args, **applied_kwargs) {
      ->(*args, **kw) {
        all_args = applied_args + args
        kwargs = applied_kwargs.merge(kw)
        return self.(*all_args, **kwargs) if apply.(all_args, kwargs.keys)
        factory.(*all_args, **kwargs)
      }
    }

    # factory and apply are defined in this closure so they can access
    # required_positionals, maximum_positionals, keyreqs, keyopts, keyrest
    # as well as self (original lambda) to eventually invoke it

    # invoke factory (with no args) to curry the lambda initially
    # return the curried lambda it returns
    factory.()
  end

  refine Proc do
    define_method :kwurry, Kwurry.instance_method(:kwurry)
  end
end
