require 'i18n'
require 'i18n/globals/version'

module I18n
  FAKE_INTERPOLATION_HASH = { fake_: :_interpolation }.freeze

  class Config
    class CachedGlobals < Hash
      def []=(key, val)
        clear_cache
        annotate_hash(val) if val.is_a?(Hash) # see annotate hash below why whis must be done
        super(key, val)
      end

      def for_locale(locale)
        if key?(locale)
          globals_cache[locale] ||= merge(fetch(locale)).select { |_, i| !i.is_a?(Hash) }
        else
          globals_cache[:default] ||= select { |_, i| !i.is_a?(Hash) }
        end
      end

      def clear
        clear_cache
        super
      end

      def merge!(val)
        clear_cache
        # see annotate hash below why whis must be done
        val.select { |_, v| v.is_a?(Hash) }.each { |_, v| annotate_hash(v) }
        super(val)
      end

      private

      def globals_cache
        @globals_cache ||= {}
      end

      def clear_cache
        @globals_cache = {}
      end

      # This is a little bit cumbersome. It might happen that this is done:
      #
      #     I18n.config.globals[:en][:welcome] = 'Hello'
      #
      # What this does is changing the locale dependent version of `welcome`.
      # Unfortunately we only override `:[]=` for our globals hash so it
      # does not detect that the globals have been changed.
      #
      # To overcome this we annotate every hash that might passed in with this
      # method. So when the sub hash is changed like above, the whole cache
      # is cleared like it should.
      def annotate_hash(hash)
        return if hash.instance_variable_defined?(:@cached_global)
        hash.instance_variable_set(:@cached_global, self)

        def hash.[]=(key, value)
          super(key, value)
          @cached_global.send(:clear_cache)
        end

        def hash.merge!(other_hash)
          super(other_hash)
          @cached_global.send(:clear_cache)
        end

        def hash.clear
          super
          @cached_global.send(:clear_cache)
        end
      end
    end

    def globals
      @@globals ||= CachedGlobals.new
    end

    def globals=(new_globals)
      globals.clear.merge!(new_globals) # maybe there is something better than `clear` and `merge!`
    end

    prepend(
      Module.new do
        def missing_interpolation_argument_handler
          @@missing_interpolation_argument_handler_with_globals ||=
            lambda do |missing_key, provided_hash, string|
              # Since the key was not found in a interpolation variable, check
              # whether it is a global. If it is, return it, so interpolation is
              # successfull.
              if globals.for_locale(locale).key?(missing_key)
                globals.for_locale(locale)[missing_key]
              else
                super.call(missing_key, provided_hash, string)
              end
            end
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

    alias :t :translate
  end
end
