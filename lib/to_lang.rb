require "to_lang/connector"
require "to_lang/translatable"
require "to_lang/translatable_meta"

$KCODE = 'u' unless RUBY_VERSION >= "1.9"

# {ToLang} is a Ruby library that adds language translation methods to strings and arrays, backed by the Google Translate API.
#
# @author Jimmy Cuadra
# @see https://github.com/jimmycuadra/to_lang Source on GitHub
#
module ToLang
  class << self
    # A {ToLang::Connector} object to use for translation requests.
    #
    # @return [ToLang::Constructor, NilClass] An initialized {ToLang::Connector connector} or nil.
    #
    attr_reader :connector

    # Initializes {ToLang}, after which the translation methods will be available from strings and arrays.
    #
    # @param [String] key A Google Translate API key.
    #
    # @return [Class, Boolean] @Array@ if initialization succeeded, @false@ if this method has already been called successfully.
    #
    def start(key, disable_meta_magic = false)
      return false if defined?(@connector) && !@connector.nil?
      @connector = Connector.new key
      String.send :include, Translatable
      Array.send :include, Translatable
      unless disable_meta_magic
        String.send :include, TranslatableMeta
        Array.send :include, TranslatableMeta
      end
    end
  end
end
