include_set Abstract::MetricChild, generation: 3
include_set Abstract::MetricAnswer

def related_company
  cardname.tag
end

def related_company_card
  Card[cardname.tag]
end

def name_parts
  %w[metric company year related_company]
end

def valid_related_company?
  (related_company_card && related_company_card.type_id == WikirateCompanyID) ||
    ActManager.include?(related_company)
end

def valid_value_name?
  super && valid_related_company?
end

# has to happen after :set_answer_name,
# but always, also if :set_answer_name is not executed
event :add_count_answer, :prepare_to_store do
  count = company_count
  count += 1 if @action == :create
  add_count answer_name, count
end

event :add_inverse_count_answer, :prepare_to_store do
  count = inverse_company_count
  count += 1 if @action == :create
  add_count inverse_answer_name, count
end

def add_count name, count
  add_subcard name, type_id: MetricValueID,
                    subfields: { value: { content: count } }
end

# number of companies that have a relationship answer for this answer
def company_count
  return 0 unless answer_id
  Card.search left_id: answer_id,
              right: { type_id: WikirateCompanyID },
              return: :count
end

def inverse_company_count
  return 0 unless inverse_answer_id
  Card.search left_id: inverse_answer_id,
              right: { type_id: WikirateCompanyID },
              return: :count
end

def answer_id
  @answer_id ||= Card.fetch_id answer_name
end

def answer_name
  cardname.left
end

def inverse_answer_name
  [metric_card.inverse, related_company, year].join "+"
end

def inverse_answer_id
  @inverse_answer_id ||= Card.fetch_id inverse_answer_name
end

format :html do
  def default_value_link_args _args
    voo.show! :link if card.relationship?
  end

  view :open_content do
    bs do
      layout do
        row 3, 9 do
          column value_field
          column do
            row 12 do
              column _render_answer_details
            end
          end
        end
      end
    end
  end

  view :content_formgroup, template: :haml do
    card.add_subfield :year, content: card.year
    card.add_subfield :related_company, content: card.related_company
  end

  def legend
    return if currency.present?
    subformat(card.metric_card).value_legend
  end
end
