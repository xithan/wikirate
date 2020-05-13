# Specifies the structure of a import item for an answer import.
class AnswerImportItem < ImportItem
  @columns = { metric: { map: true },
               wikirate_company: { map: true },
               year: { map: true },
               value: {},
               source: { map: true, separator: ";" },
               comment: { optional: true } }

  def import_hash
    return {} unless (metric_card = Card[metric])

    metric_card.create_answer_args translate_row_hash_to_create_answer_hash
  end

  def normalize_value val
    if Card[metric]&.try :categorical? # really only needed for multicategory...
      val.split(";").compact.map(&:strip)
    else
      val
    end
  end

  def map_source val
    result = Card::Set::Self::Source.search val
    # result.first.id if result.size == 1
    #
    # FIXME: below is temporary solution to speed along FTI duplicates.
    # above is preferable once we have matching.
    result.first&.id
  end

  def translate_row_hash_to_create_answer_hash
    r = @row.clone
    translate_company_args r
    r[:year] = r[:year].cardname if r[:year].is_a?(Integer)
    r[:ok_to_exist] = true
    prep_subfields r
  end

  def translate_company_args item
    item[:company] = item.delete :wikirate_company
  end
end