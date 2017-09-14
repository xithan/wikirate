format :html do
  def year
    return card.fetch(trait: :year).content if card.fetch(trait: :year)
    ""
  end

  def wrap_with_info
    wrap do
      wrap_with :div, class: "source-info-container" do
        yield
      end
    end
  end

  def with_toggle
    # voo.hide! :links   # doesn't work with voo
    @links = false
    wrap_with :div, class: "source-details-toggle",
                    data: { source_for: card.name, year: year } do
      yield.html_safe
    end
  end

  def edit_slot
    voo.editor = :inline_nests
    super
  end

  def website_text
    website_field = card.field :wikirate_website, new: {}
    nest website_field, view: :content, items: { view: :name }
  end

  def title_text
    nest(card.source_title_card, view: :needed)
  end

  def source_item_footer
    [
      (_render_year_with_icon if year.present?),
      (_render_metric_count if with_links?),
      (_render_note_count if with_links?),
      (_render_original_with_icon if with_links?)
    ].compact
  end

  def icon
    # default as link
    "globe"
  end

  view :listing, template: :haml

  view :original_with_icon do
    icon = wrap_with(:i, " ", class: "fa fa-external-link-square")
    icon + _render_original_link
  end

  view :icon do
    icon = wrap_with(:i, " ", class: "glyphicon glyphicon-link")
    wrap_with(:div, icon, class: "source-icon")
  end

  view :creator_credit do
    wrap_with :div, class: "last-edit" do
      "added #{_render_created_at} ago by #{creator}"
    end
  end

  def creator
    # FIXME: codename!
    field_nest "*creator", view: :core, items: { view: :link }
  end

  view :website_link do |_args|
    link_to_card card, website_text, class: "source-preview-link",
                                     target: "_blank"
  end

  view :title_link do |_args|
    link_to_card card, title_text,
                 target: "_blank",
                 class: "source-preview-link preview-page-link"
  end

  view :source_link do
    wrap_with :div, class: "source-link" do
      [
        wrap_with(:span, source_website, class: "source-website"),
        wrap_with(:i, "", class: "fa fa-long-arrow-right"),
        wrap_with(:span, source_title, class: "source-title")
      ]
    end
  end

  def with_links?
    @links != false
  end

  def source_website
    with_links? ? _render_website_link : website_text
  end

  def source_title
    with_links? ? _render_title_link : title_text
  end

  view :year_helper do
    return "" if year.nil? || year == ""
    wrap_with(:small, "year:" + year[/\d+/], class: "source-year")
    # _render_original_link << year_helper.html_safe
  end

  view :year_with_icon do
    return "" if year.nil? || year == ""
    icon = wrap_with(:i, "", class: "fa fa-calendar")
    wrap_with(:span, icon + year[/\d+/])
  end

  view :direct_link do
    return "" unless card.source_type_codename == :wikirate_link
    link = card.fetch(trait: :wikirate_link).content
    wrap_with :a, href: link, target: "_blank" do
      [wrap_with(:i, class: "fa fa-external-link-square cursor"), "Original"]
    end
  end

  def with_cite_button cited: false
    voo.hide :links
    wrap_with_info do
      [
        _render_listing,
        cite_button(cited),
        (hidden_item_input if cited)
      ]
    end
  end

  def cite_button cited
    text = cited ? "Cited!" : "Cite!"
    cite_class =
      cited ? "btn-success _cited_button" : "btn-highlight _cite_button"
    wrap_with(:div, class: "pull-right") do
      wrap_with :a, text, href: "#", class: "btn #{cite_class} c-btn"
    end
  end

  def hidden_item_input
    tag :input, type: "hidden", class: "pointer-select _no-chosen", value: card.name
  end

  view :with_cited_button do
    with_toggle do
      with_cite_button(cited: true)
    end
  end

  view :source_and_preview, cache: :never do |args|
    wrap_with :div, class: "source-details",
                    data: { source_for: card.name, year: year } do
      args[:url] = source_url
      with_cite_button +
        render_iframe_view(args).html_safe +
        render_hidden_information(args).html_safe
    end
  end

  def source_url
    url_card = card.fetch(trait: :wikirate_link)
    url_card ? url_card.item_names.first : nil
  end

  view :relevant do
    with_toggle do
      with_cite_button
    end
  end

  view :cited, cache: :never do |args|
    if voo.show? :cited_source_links
      wrap_with_info { _render_listing args }
    else
      with_toggle do   F
        wrap_with_info { _render_listing args }
      end
    end
  end

  view :metric_import_link do
    ""
  end

  view :original_icon_link do
    voo.title = fa_icon icon
    _render_original_link
  end

  view :content do
    add_name_context
    super()
  end

  view :missing do
    _view_link
  end

  # TODO: reuse the following in source_preview.rb
  view :metric_count do
    pretty_count :metric, "bar-chart"
  end

  view :note_count do
    pretty_count "note", "quote-left"
  end

  def pretty_count type, icon_name
    output(
      [
        wrap_with(:span, id: "#{type}-count-number", class: "count-number") do
          count = send "#{type}_count"
          "#{fa_icon icon_name} #{count} "
        end,
        wrap_with(:span, Card.quick_fetch(type).name.pluralize)
      ]
    )
  end
end
