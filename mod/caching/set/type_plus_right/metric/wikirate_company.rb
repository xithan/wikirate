# cache # of companies with values for metric (=_left)
include_set Abstract::AnswerTableCachedCount, target_type: :company

# recount number of companies for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_value, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch(trait: :wikirate_company)
end

def search_anchor
  { metric_id: left.id }
end
