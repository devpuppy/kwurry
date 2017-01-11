require "kwurry/version"

# module Kwurry
#   refine Proc do
#     def kwurry
#       self
#     end
#   end
# end

# using Kwurry

class Proc
  def kwurry
    keys_index = parameters.reduce(Hash.new { |h,k| h[k] = [] }) { |h, (type, name)| h[type] << name; h }
    keyreqs = keys_index[:keyreq]
    keyopts = keys_index[:key]
    keyrest = keys_index[:keyrest].any?

    apply = ->(keys) {
      if !keyrest
        invalid_keys = (keys - (keyreqs + keyopts))
        raise ArgumentError.new("invalid keys: #{invalid_keys}") if invalid_keys.any?
      end
      (keyreqs - keys).empty?
    }
    # factory = ->() {
    #   ->(**kwargs) {
    #     return self.(**kwargs) if apply.(kwargs.keys)
    #     applied_kwargs = kwargs
    #     f = factory.()
    #     ->(**kwargs) { f.(**applied_kwargs.merge(kwargs)) }
    #   }
    # }

    factory = -> (**applied_kwargs) {
      ->(**kw) {
        kwargs = applied_kwargs.merge(kw)
        return self.(**kwargs) if apply.(kwargs.keys)
        factory.(**kwargs)
      }
    }

    factory.()
  end
end
