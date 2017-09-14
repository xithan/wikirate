def ids_related_to_research_group research_group
  research_group.projects.map do |project|
    Answer.where(
      company_id: project.company_ids,
      metric_id: project.metric_ids
    ).pluck :answer_id
  end.flatten
end

# def report_query action, user_id, subvariant
#   answer_query = send("#{action}_query", user_id, subvariant)
#   #answer_ids = Answer.where(answer_query).pluck(:answer_id)
#   #{ id: ["in"] + answer_ids, limit: 5 }
# end

def subvariants
  {
    created: [:checked_by_others, :updated_by_others, :discussed_by_others],
    updated_on: [:checked]
  }
end

def updated_query user_id, variant=nil
  if variant == :checked
    { right_plus: [CheckedByID, { refer_to: user_id }] }
  else
    { right_plus: [ValueID, { updated_by: user_id }] }
  end
end

def created_query user_id, variant=nil
  super.merge(created_query_variant(user_id, variant))
end

def created_query_variant user_id, variant=nil
  case variant
  when :checked_by_others
    { right_plus: [CheckedByID,
                   { refer_to: { not: { id: ["in", RequestID, user_id] } } }] }
  when :updated_by_others
    { right_plus: [ValueID, { updated_by: { not: { id: user_id } } }] }
  when :discussed_by_others
    { right_plus: [DiscussionID, { edited_by: { not: { id: user_id } } }] }
  else
    {}
  end
end
