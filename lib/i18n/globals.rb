require 'i18n'
require 'i18n/globals/version'

module I18n
  FAKE_INTERPOLATION_HASH = { fake_: :_interpolation }.freeze

  class Config
    class CachedGlobals
      @locale_hashes = {}
      @defaults = {}

      def initialize(hash = nil)
        return unless hash

        @locale_hashes, @defaults = hash.partition { |_, v| v.is_a?(Hash) }.map(&:to_h)
      end

      def []=(key, val)
        val.is_a?(Hash) ? @locale_hashes[key] = val : @defaults[key] = val
      end

      def [](key)
        @locale_hashes[key] || @defaults[key]
      end

      def merge!(val)
        locale_hashes, defaults = val.partition { |_, v| v.is_a?(Hash) }.map(&:to_h)
        @locale_hashes.merge!(locale_hashes)
        @defaults.merge!(defaults)
        self
      end

      private

      # Returns the value of the global for that locale or the default as fallback
      def for_locale(key, locale)
        @locale_hashes[locale] && @locale_hashes[locale][key] || @defaults[key]
      end

      # Returns all globals for current locale. Since this is a combination
      # of default and locale globals, the hash is frozen so that it is not
      # manipulated by accident (that would have no effect on globals).
      #
      # To change locale dependent hashes during runtime, use `:[]` to fetch
      # locale globals without defaults:
      #
      #     I18n.config.globals[:en][:new_name] = 'James'
      #
      def all_for_locale(locale)
        (
          @locale_hashes[locale] && @defaults.merge(@locale_hashes[locale]) ||
            @defaults.dup
        ).freeze
      end
    end

    def globals(locale = nil)
      @@globals ||= CachedGlobals.new # rubocop:disable Style/ClassVars
      locale.nil? && @@globals || @@globals.send(:all_for_locale, locale)
    end

    # rubocop:disable Style/ClassVars
    def globals=(new_globals, locale = nil)
      locale.nil? ? @@globals = CachedGlobals.new(new_globals) : globals[locale] = new_globals
    end

    def global(key, loc = locale)
      globals.send(:for_locale, key, loc)
    end

    prepend(
      Module.new do
        def missing_interpolation_argument_handler
          @@missing_interpolation_argument_handler_with_globals ||=
            lambda do |missing_key, provided_hash, string|
              # Since the key was not found in a interpolation variable, check
              # whether it is a global. If it is, return it, so interpolation is
              # successfull.
              global(missing_key) || super.call(missing_key, provided_hash, string)
            end
          # rubocop:enable Style/ClassVars
        end
      end
    )
  end

  class << self
    def translate(*args)
      # If last argument is a hash, interpolation will be run. If not, it will
      # not even attempt to interpolate something and our custom
      # `missing_interpolation_argument_handler` will not be run at all. That's
      # why we pass in a fake hash so that it always runs interpolation.
      args << FAKE_INTERPOLATION_HASH unless args.last.is_a?(Hash)
      super(*args)
    end

    alias t translate
  end
end
