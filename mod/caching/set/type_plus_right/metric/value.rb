# cache # of values for left metric
include_set Abstract::AnswerTableCachedCount, target_type: :answer

def search_anchor
  { metric_id: left.id }
end

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_value, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch(trait: :value)
end
