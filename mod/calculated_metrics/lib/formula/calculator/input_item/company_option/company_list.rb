module Formula
  class Calculator
    class InputItem
      module CompanyOption
        module CompanyList
          include CompanyIndependentInput

          def each_answer
            years_from_db(object_company_ids).each do |year|
              yield nil, year, values_from_db(object_company_ids, year)
            end
          end

          def values_by_year_for_each_company
            v_by_y = years_from_db(object_company_ids).each_with_object({}) do |y, h|
              h[y.to_i] = values_from_db object_company_ids, y
            end
            yield nil, v_by_y
          end

          def object_company_ids
            @o_ids ||=
              company_option.split(",").map do |comp|
                Card.fetch_id comp
              end.compact
          end
        end
      end
    end
  end
end