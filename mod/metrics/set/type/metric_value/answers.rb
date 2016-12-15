format :html do
  view :closed_answer do
    class_up "vis", "pull-left"
    output [
      row,
      wrap_with(:div, "", class: "card-slot collapse answer-details text-muted")
    ]
  end

  def row
    wrap_with :div, class: "row" do
      [
        _render_answer_details_toggle,
        value_field,
        _render_chart
      ]
    end
  end

  def value_field
    wrap_with :div, class: "value pull-left" do
      [
        wrap_with(:span, currency, class: "metric-unit"),
        _render_value_link,
        wrap_with(:span, legend, class: "metric-unit"),
        _render_flags
      ]
    end
  end

  view :flags do
    output [checked_value_flag, comment_flag]
  end

  view :answer_details do
    value_details
  end

  view :answer_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 "\
                "btn btn-default btn-sm pull-right"
    wrap_with(:i, "",
              class: css_class,
              data: { toggle: "collapse",
                      url: path(view: :answer_details),
                      target: ".answer-details",
                      collapse_icon_in: "fa-caret-down",
                      collapse_icon_out: "fa-caret-right" })
  end

  view :plain_year do
    card.cardname.right
  end
end
