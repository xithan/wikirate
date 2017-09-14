def number? str
  true if Float(str)
rescue
  false
end

# returns with a tenth (eg 11.1%)
def percent numerator, denominator
  denominator.zero? ? 0 : (1000 * numerator / denominator / 10.0)
end

format do
  def humanized_number value
    number = BigDecimal.new(value)
    size = number.abs > 1_000_000 ? :big : :small
    send "humanized_#{size}_number", number
  end

  def humanized_big_number number
    number_to_human number, format: "%n%u", delimiter: "", precision: 3
  end

  def humanized_small_number number
    less_than_one = number.abs < 1
    humanized = number_with_precision(
      number, delimiter: ",", strip_insignificant_zeros: true,
              precision: (less_than_one ? 3 : 1), significant: less_than_one
    )
    humanized == "0" && number > 0 ? "~0" : humanized
  end
end
