DETAILS_FIELD_MAP = {
  number: :numeric_details,
  money: :monetary_details,
  category: :category_details,
  multi_category: :category_details
}.freeze

format :html do
  view :bar do
    wrap_with :div, class: "contribution-item value-item no-hover" do
      [
        wrap_with(:div, class: "header") do
          _render_thumbnail
        end,
        wrap_with(:div, class: "text-center") do
          bar_data
        end
      ]
    end
  end

  def bar_data
    wrap_with :div, class: "contribution company-count p-2" do
      [
        wrap_with(:span, company_count, class: "badge badge-secondary"),
        wrap_with(:span, rate_subjects, class: "text-muted")
      ]
    end
  end

  def company_count
    card.fetch(trait: :wikirate_company).cached_count
  end

  view :legend do
    value_legend
  end

  view :legend_core do
    value_legend false
  end

  def value_legend html=true
    # depends on the type
    if card.unit.present?
      card.unit
    elsif card.range.present?
      card.range.to_s
    elsif card.categorical?
      category_legend_display html
    else
      ""
    end
  end

  def category_legend_display html
    html ? category_legend_div : category_legend.gsub!("<br>", "")
  end

  def category_legend_div
    wrap_with :div, class: "small" do
      [
        fa_icon("list"),
        category_legend.gsub!("<br>", "")[0..40],
        " ",
        popover_link_custom(category_legend)
      ]
    end
  end

  def popover_link_custom text, title=nil
    opts = { class: "pl-1 text-muted-link border text-muted px-1",
             path: "javascript:", "data-toggle": "popover",
             "data-trigger": :focus, "data-content": text, "data-html": "true" }
    opts["data-title"] = title if title
    link_to fa_icon("ellipsis-h"), opts
  end

  def category_legend
    card.value_options.reject { |o| o == "Unknown" }.join ", <br>"
  end

  view :handle do
    wrap_with :div, class: "handle" do
      glyphicon "option-vertical"
    end
  end

  view :vote do
    %(<div class="hidden-xs hidden-md">
    #{field_nest(:vote_count)}</div>
    )
  end

  view :value do
    return "" unless args[:company]
    %(
      <div class="data-item hide-with-details">
        {{#{safe_name}+#{h args[:company]}+latest value|concise}}
      </div>
    )
  end

  view :metric_info do
    question = subformat(card.question_card)._render_core.html_safe
    rows = [
      icon_row("question", question, class: "metric-details-question"),
      icon_row("bar-chart", card.metric_type, class: "text-emphasized"),
      icon_row("tag", field_nest("+topic", view: :content, items: { view: :link }))
    ]
    if card.researched?
      rows << text_row("Unit", field_nest("Unit"))
      rows << text_row("Range", field_nest("Range"))
    end
    wrap_with :div, class: "metric-info" do
      rows
    end
  end

  def metric_info_row left_structure, right_content, opts={}
    <<-HTML
      <div class="row #{opts[:class]}">
        #{left_structure}
        <div class="row-data">
          #{right_content}
        </div>
      </div>
    HTML
  end

  def text_row text, content, opts={}
    left = <<-HTML
            <div class="left-col">
              <strong>#{text}</strong>
            </div>
    HTML
    metric_info_row left, content, opts
  end

  def icon_row icon, content, opts={}
    left = <<-HTML
            <div class="left-col icon-muted">
              #{fa_icon icon}
            </div>
    HTML
    metric_info_row left, content, opts
  end

  def weight_content weight
    icon_class = "pull-right _remove-weight btn btn-outline-secondary btn-sm"
    wrap_with :div do
      [text_field_tag("pair_value", weight) + "%",
       content_tag(:span, fa_icon(:close).html_safe, class: icon_class)]
    end
  end

  def weight_row weight=0, label=nil
    label ||= _render_thumbnail_no_link
    weight = weight_content weight
    output([wrap_with(:td, label, class: "metric-label"),
            wrap_with(:td, weight, class: "metric-weight")]).html_safe
  end

  def interpret_year year
    case year
    when /^[+-]\d+$/ then "year#{args[:year]}"
    when /^\d{4}$/   then year
    when "0"         then "year"
    end
  end

  def get_value_str year
    "data[#{card.key}][#{year}]"
  end

  # view :ruby, cache: :never do |args|
  #   if args[:sum]
  #     start, stop = args[:sum].split("..").map { |y| interpret_year(y) }
  #     "((#{start}..#{stop}).to_a.inject(0) " \
  #     "{ |r, y| r += #{get_value_str('y')}; r })"
  #   else
  #     year = args[:year] ? interpret_year(args[:year]) : "year"
  #     get_value_str year
  #   end
  # end

  def prepare_for_outlier_search
    res = {}
    card.all_metric_values_card.values_by_name.map do |key, data|
      data.each do |row|
        res["#{key}+#{row['year']}"] = row["value"].to_i
      end
    end
    res
  end

  view :outliers do
    outs = Savanna::Outliers.get_outliers prepare_for_outlier_search, :all
    outs.inspect
  end
end
