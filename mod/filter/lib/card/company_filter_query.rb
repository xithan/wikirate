class Card
  class CompanyFilterQuery < FilterQuery
    INDUSTRY_METRIC_NAME = "Global Reporting Initiative+Sector Industry"
    INDUSTRY_VALUE_YEAR = "2015"

    def wikirate_topic_wql value
      add_to_wql :found_by, value.to_name.trait(:wikirate_company)
    end

    def industry_wql industry
      return unless industry.present?
      @filter_wql[:left_plus] <<
        self.class.industry_wql(industry)[:left_plus]
    end

    def self.industry_wql industry
      {
        left_plus:
          [
            INDUSTRY_METRIC_NAME,
            {
              right_plus: [
                INDUSTRY_VALUE_YEAR,
                { right_plus: ["value", { eq: industry }] }
              ]
            }
          ]
      }
    end
  end
end
