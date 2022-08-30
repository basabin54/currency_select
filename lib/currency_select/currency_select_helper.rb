module ActionView
  module Helpers
    class FormBuilder
      def currency_select(method, priority_or_options = {}, options = {}, html_options = {})
        if Hash === priority_or_options
          html_options = options
          options = priority_or_options
        else
          if RUBY_VERSION =~ /^3\.\d\.\d/
            warn "DEPRECATION WARNING: Setting priority currencies with the 1.x syntax is deprecated. Please use the `priority_currencies:` option.", uplevel: 1, category: :deprecated
          else
            warn "DEPRECATION WARNING: Setting priority currencies with the 1.x syntax is deprecated. Please use the `priority_currencies:` option.", uplevel: 1
          end
          options[:priority_currencies] = priority_or_options
        end

        @template.currency_select(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end
    end

    module FormOptionsHelper
      def currency_select(object, method, options = {}, html_options = {})
        Tags::CurrencySelect.new(object, method, self, options, html_options).render
      end
    end

    module Tags
      class CurrencySelect < Base
        include ::CurrencySelect::TagHelper

        def initialize(object_name, method_name, template_object, options, html_options)
          @html_options = html_options

          super(object_name, method_name, template_object, options)
        end

        def render
          select_content_tag(currency_option_tags, @options, @html_options)
        end
      end
    end
  end
end
