module CurrencySelect
  FORMATS = {}

  FORMATS[:default] = lambda do |currency|
    "#{currency.iso_code} - #{currency.name}"
  end
end
