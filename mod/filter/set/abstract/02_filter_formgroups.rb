include_set Abstract::FilterFormHelper

format :html do
  view :name_formgroup, cache: :never do
    text_filter :name
  end

  view :project_formgroup, cache: :never do
    select_filter_type_based :project
  end

  view :year_formgroup, cache: :never do
    select_filter :year, "Year", "most recent"
  end

  view :wikirate_topic_formgroup, cache: :never do
    # select_filter_type_based :wikirate_topic
    autocomplete_filter :wikirate_topic
  end

  view :metric_formgroup, cache: :never do
    # select_filter_type_based :metric
    autocomplete_filter :metric
  end

  view :wikirate_company_formgroup, cache: :never do
    # select_filter_type_based :wikirate_company
    autocomplete_filter :wikirate_company
  end

  view :research_policy_formgroup, cache: :never do
    checkbox_filter :research_policy, "Research Policy"
  end

  def research_policy_select
    select_filter_type_based :research_policy
  end

  view :metric_type_formgroup, cache: :never do
    checkbox_filter :metric_type, "Metric Type"
  end

  def metric_type_select
    select_filter :metric_type, "Metric Type"
  end

  view :metric_value_formgroup, cache: :never do
    select_filter :metric_value, "Value", "exists"
  end

  view :designer_formgroup, cache: :never do
    select_filter :designer, "Designer"
  end

  view :importance_formgroup, cache: :never do
    checkbox_filter :importance, "My Vote", %w[upvotes novotes]
  end

  view :industry_formgroup, cache: :never do
    select_filter :industry, "Industry"
  end

  view :sort_formgroup, cache: :never do
    selected_option = sort_param || card.default_sort_option
    options = options_for_select(sort_options, selected_option)
    formgroup "Sort", class: "filter-input " do
      select_tag "sort", options, class: "pointer-select"
    end
  end

  def sort_options
    {}
  end

  def default_year_option
    { "Most Recent" => "latest" }
  end

  def year_options
    type_options(:year).each_with_object(default_year_option) do |v, h|
      h[v] = v
    end
  end

  def metric_value_options
    opts = {
      "All" => "all",
      "Researched" => "exists",
      "Known" => "known",
      "Unknown" => "unknown",
      "Not Researched" => "none",
      "Edited today" => "today",
      "Edited this week" => "week",
      "Edited this month" => "month",
      "Outliers" => "outliers"
    }
    return opts unless filter_param(:range)
    opts.each_with_object({}) do |(k, v), h|
      h[add_range(k, v)] = v
    end
  end

  def add_range key, _value
    key # unless selected_value?(value)
    # range = filter_param :range
    # "#{range[:from]} <= #{key} < #{range[:to]}"
  end

  def selected_value? value
    (filter_param(:metric_value) && value == filter_param(:metric_value)) ||
      value == "exists"
  end

  def metric_type_options
    [:researched, :formula, :wiki_rating].map { |n| Card.quick_fetch(n).name }
  end

  def research_policy_options
    type_options :research_policy
  end

  def importance_options
    { "I voted FOR" => :upvotes,
      "I voted AGAINST" => :downvotes,
      "I did NOT vote" => :novotes }
  end

  def industry_options
    card_name = CompanyFilterQuery::INDUSTRY_METRIC_NAME
    Card[card_name].value_options
  end

  def designer_options
    metrics = Card.search type_id: MetricID, return: :name
    metrics.map do |m|
      names = m.to_name.parts
      # score metric?
      names.length == 3 ? names[2] : names[0]
    end.uniq!(&:downcase).sort_by!(&:downcase)
  end
end
