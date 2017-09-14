format :html do
  def tab_list
    {
      details_tab: "Details",
      discussion_tab: "#{fa_icon :comment} Discussion",
      project_tab: "Projects"
    }
  end

  # tabs for metrics of type formula, score and WikiRating
  # overridden for researched
  view :details_tab do
    tab_wrap do
      output [
        _render_metric_properties,
        wrap_with(:hr, ""),
        nest(card.formula_card, view: :titled, title: "Formula"),
        nest(card.about_card, view: :titled, title: "About")
      ]
    end
  end

  view :discussion_tab do
    tab_wrap do
      field_nest :discussion, view: :titled,
                              hide: [:header, :title],
                              show: "comment_box"
    end
  end

  view :project_tab do
    tab_wrap do
      field_nest :project, view: :titled,
                           title: "Projects",
                           items: { view: :listing }
    end
  end
end
