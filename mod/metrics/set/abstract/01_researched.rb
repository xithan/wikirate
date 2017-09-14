def score_cards
  # we don't check the metric type
  # we assume that a metric with left is a metric again is always a score
  Card.search type_id: MetricID,
              left_id: id
end

format :html do
  def default_content_formgroup_args _args
    super _args
    voo.edit_structure += [
      [:value_type, "Value Type"],
      [:research_policy, "Research Policy"],
      [:report_type, "Report Type"]
    ]
  end

  def tab_list
    super.merge source_tab: "#{fa_icon :globe} Sources",
                scores_tab: "Scores"
  end

  view :details_tab do
    tab_wrap do
      wrap_with :div, class: "metric-details-content" do
        [
          _render_metric_properties,
          wrap_with(:hr, ""),
          nest(card.about_card, view: :titled, title: "About"),
          nest(card.methodology_card, view: :titled, title: "Methodology"),
          _render_import_button,
          _render_add_value_buttons
        ]
      end
    end
  end

  view :value_type_detail do
    wrap_with :div do
      [
        _render_value_type_edit_modal_link,
        _render_short_view
      ]
    end
  end

  view :source_tab do
    tab_wrap do
      field_nest :source, view: :titled,
                          title: "#{fa_icon 'globe'} Sources",
                          items: { view: :listing }
    end
  end

  view :scores_tab do |args|
    # TODO: move +scores to a separate card
    tab_wrap do
      wrap_with :div, class: "list-group" do
        card.score_cards.map do |item|
          subformat(item)._render_score_thumbnail(args)
        end
      end
    end
  end

  def add_value_link
    link_to_card :research_page, "#{fa_icon 'plus'} Add new value",
                 path: { metric: card.name, view: :new },
                 class: "btn btn-primary"
    # "/new/metric_value?metric=" + _render_cgi_escape_name
  end

  view :add_value_buttons do
    return unless card.user_can_answer?
    wrap_with :div, class: "row margin-no-left-15" do
      add_value_link
    end
  end

  view :import_button do
    <<-HTML
      <h5>Bulk Import</h5>
        <div class="btn-group" role="group" aria-label="...">
          <a class="btn btn-default btn-sm" href='/new/source?layout=wikirate%20layout'>
            <span class="fa fa-arrow-circle-o-down"></span>
            Import
          </a>
          <a class="btn btn-default btn-sm slotter"
             href='/import_metric_values?layout=modal'
             data-toggle='modal' data-target='#modal-main-slot'>
            Help <small>(how to)</small>
          </a>
        </div>
    HTML
  end
end

def user_can_answer?
  policy = fetch(trait: :research_policy, new: {}).item_cards.first.name
  is_admin = Auth.always_ok?
  is_owner = Auth.current.id == creator.id
  is_designer_assessed = policy.casecmp("designer assessed").zero?
  # TODO: add metric designer respresentative logic here
  !is_designer_assessed || (is_admin || is_owner)
end
