module ActionView
  module Helpers
    class FormBuilder
      def currency_select(method, priority_or_options = {}, options = {}, html_options = {})
        if priority_or_options.is_a? Hash
          html_options = options
          options = priority_or_options
        else
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
