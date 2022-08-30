module CurrencySelect
  class CurrencyNotFoundError < StandardError;end
  module TagHelper
    def currency_option_tags
      # In Rails 5.2+, `value` accepts no arguments and must also be called
      # with parens to avoid the local variable of the same name
      # https://github.com/rails/rails/pull/29791
      selected_option = @options.fetch(:selected) do
        if self.method(:value).arity == 0
          value()
        else
          value(@object)
        end
      end

      option_tags_options = {
        :selected => selected_option,
        :disabled => @options[:disabled]
      }

      if priority_currencies.present?
        priority_currencies_options = currency_options_for(priority_currencies, @options.fetch(:sort_provided, ::CurrencySelect::DEFAULTS[:sort_provided]))

        option_tags = options_for_select(priority_currencies_options, option_tags_options)
        option_tags += html_safe_newline + options_for_select([priority_currencies_divider], disabled: priority_currencies_divider)

        option_tags_options[:selected] = [option_tags_options[:selected]] unless option_tags_options[:selected].kind_of?(Array)
        option_tags_options[:selected].delete_if{|selected| priority_currencies_options.map(&:second).include?(selected)}

        option_tags += html_safe_newline + options_for_select(currency_options, option_tags_options)
      else
        option_tags = options_for_select(currency_options, option_tags_options)
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
      currency_options_for(all_currency_codes, @options.fetch(:sort_provided, ::CurrencySelect::DEFAULTS[:sort_provided]))
    end

    def all_currency_codes
      codes = Money::Currency.codes

      if only_currency_codes.present?
        only_currency_codes & codes
      elsif except_currency_codes.present?
        codes - except_currency_codes
      else
        codes
      end
    end

    def currency_options_for(currency_codes, sorted=true)
      I18n.with_locale(locale) do
        currency_list = currency_codes.map do |code_or_name|
          if currency = Money::Currency.new(code_or_name)
            code = currency.iso_code
          # elsif currency = Money::Currency.find_currency_by_any_name(code_or_name)
          #   code = currency.alpha2
          end

          unless currency.present?
            msg = "Could not find Currency with string '#{code_or_name}'"
            raise CurrencyNotFoundError.new(msg)
          end

          formatted_currency = ::CurrencySelect::FORMATS[format].call(currency)

          if formatted_currency.is_a?(Array)
            formatted_currency
          else
            [formatted_currency, code]
          end

        end

        if sorted
          currency_list.sort_by { |name, code| [I18n.transliterate(name), name] }
        else
          currency_list
        end
      end
    end

    def html_safe_newline
      "\n".html_safe
    end
  end
end
