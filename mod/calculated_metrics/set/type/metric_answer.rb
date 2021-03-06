
# The answers that a
def direct_dependee_answers
  return [] if researched_value?

  metric_card.calculator.answers(company: company_id, year: year).uniq
end

def dependee_answers
  direct_dependee_answers.tap do |answers|
    answers << answers.map(&:dependee_answers)
    answers.flatten!.uniq!
  end
end

def researched_dependee_answers
  dependee_answers.select(&:researched_value?)
end

def calculated_verification
  dependee_answers.map(&:verification).compact.min || 1
end
