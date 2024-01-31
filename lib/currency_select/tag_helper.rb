module CurrencySelect
  class CurrencyNotFoundError < StandardError; end

  module TagHelper
    unless respond_to?(:options_for_select)
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::Tags::SelectRenderer if defined?(ActionView::Helpers::Tags::SelectRenderer)
    end

    def currency_option_tags
      selected_option = @options.fetch(:selected) do
        if self.method(:value).arity.zero?
          value()
        else
          value(@object)
        end
      end

      option_tags_options = {
        selected: selected_option,
        disabled: @options[:disabled]
      }

      if priority_currencies.present?
        options_for_select_with_priority_currencies(currency_options, option_tags_options)
      else
        options_for_select(currency_options, option_tags_options)
      end
    end

    private

    def locale
      @options.fetch(:locale, ::CurrencySelect::DEFAULTS[:locale])
    end

    def priority_currencies
      @options.fetch(:priority_currencies, ::CurrencySelect::DEFAULTS[:priority_currencies])
    end

    def priority_currencies_divider
      @options.fetch(:priority_currencies_divider, ::CurrencySelect::DEFAULTS[:priority_currencies_divider])
    end

    def only_currency_codes
      @options.fetch(:only, ::CurrencySelect::DEFAULTS[:only])
    end

    def except_currency_codes
      @options.fetch(:except, ::CurrencySelect::DEFAULTS[:except])
    end

    def format
      @options.fetch(:format, ::CurrencySelect::DEFAULTS[:format])
    end

    def currency_options
      codes = ISO3166::Currency.codes

      if only_currency_codes.present?
        codes = only_currency_codes & codes
        sort = @options.fetch(:sort_provided, ::CurrencySelect::DEFAULTS[:sort_provided])
      else
        codes -= except_currency_codes if except_currency_codes.present?
        sort = true
      end

      currency_options_for(codes, sorted: sort)
    end

    def currency_options_for(currency_codes, sorted: true)
      I18n.with_locale(locale) do
        currency_list = currency_codes.map { |code_or_name| get_formatted_currency(code_or_name) }

        currency_list.sort_by! { |name, _| [I18n.transliterate(name.to_s), name] } if sorted
        currency_list
      end
    end

    def options_for_select_with_priority_currencies(currency_options, tags_options)
      sorted = @options.fetch(:sort_provided, ::CurrencySelect::DEFAULTS[:sort_provided])
      priority_currencies_options = currency_options_for(priority_currencies, sorted: sorted)

      option_tags = priority_options_for_select(priority_currencies_options, tags_options)

      tags_options[:selected] = Array(tags_options[:selected]).delete_if do |selected|
        priority_currencies_options.map(&:second).include?(selected)
      end

      option_tags += "\n".html_safe + options_for_select(currency_options, tags_options)

      option_tags
    end

    def priority_options_for_select(priority_currencies_options, tags_options)
      option_tags = options_for_select(priority_currencies_options, tags_options)
      option_tags += "\n".html_safe + options_for_select([priority_currencies_divider], disabled: priority_currencies_divider)
    end

    def get_formatted_currency(code_or_name)
      currency = ISO3166::Currency.new(code_or_name) || ISO3166::Currency.find_currency_by_any_name(code_or_name)

      raise(CurrencyNotFoundError, "Could not find Currency with string '#{code_or_name}'") unless currency.present?

      code = currency.alpha2
      formatted_currency = ::CurrencySelect::FORMATS[format].call(currency)

      if formatted_currency.is_a?(Array)
        formatted_currency
      else
        [formatted_currency, code]
      end
    end
  end
end
