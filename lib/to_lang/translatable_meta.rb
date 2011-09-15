require "to_lang/codemap"

module ToLang
  # {ToLang}'s core translation methods.
  #
  module TranslatableMeta
    # Chain @method_missing@ in case another library has used it.
    #
    alias_method :original_method_missing, :method_missing

    # Overrides @method_missing@ to catch and define dynamic translation methods.
    #
    # @private
    #
    def method_missing(method, *args, &block)
      case method.to_s
      when /^to_(.*)_from_(.*)$/
        if CODEMAP[$1] && CODEMAP[$2]
          define_and_call_method(method) { translate(CODEMAP[$1], :from => CODEMAP[$2]) }
        else
          original_method_missing(method, *args, &block)
        end
      when /^from_(.*)_to_(.*)$/
        if CODEMAP[$1] && CODEMAP[$2]
          define_and_call_method(method) { translate(CODEMAP[$2], :from => CODEMAP[$1]) }
        else
          original_method_missing(method, *args, &block)
        end
      when /^to_(.*)$/
        if CODEMAP[$1]
          define_and_call_method(method) { translate(CODEMAP[$1]) }
        else
          original_method_missing(method, *args, &block)
        end
      else
        original_method_missing(method, *args, &block)
      end
    end

    # Chain @respond_to?@ in case another library has used it.
    alias_method :original_respond_to?, :respond_to?

    # Overrides @respond_to?@ to make strings aware of the dynamic translation methods.
    #
    # @private
    #
    def respond_to?(method, include_private = false)
      case method.to_s
      when /^to_(.*)_from_(.*)$/, /^from_(.*)_to_(.*)$/
        return true if CODEMAP[$1] && CODEMAP[$2]
      when /^to_(.*)$/
        return true if CODEMAP[$1]
      end

      original_respond_to?(method, include_private)
    end

    private

    # Defines a method dynamically and then calls it.
    #
    # @private
    #
    def define_and_call_method(method, &block)
      self.class.send(:define_method, method, block)
      send method
    end
  end
end
