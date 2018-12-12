module Formula
  class Calculator
    class InputItem
      # Manages the two different types of input values: metrics and yearly variables
      class ValueStore
        attr_reader :years, :values

        def initialize
          @years = ::Set.new
          @companies = ::Set.new
          @values = Hash.new_nested(Hash, Hash)
        end

        def get company, year=nil
          dig_args = [company, year].compact
          dig_args.present? ? values.dig(*dig_args) : values
        end

        def companies
          @values.keys
        end

        def add company, year, value
          @years.add year
          @companies.add company
          values[company].merge!(year.to_i => value)
        end
      end
    end
  end
end