# views used to display a metric in a table row

include_set Abstract::Media
include_set Abstract::Table

format :html do
  def company_count
    card.fetch(trait: :wikirate_company).cached_count
  end

  view :company_count do
    company_count
  end

  view :company_count_with_label do
    count_with_label_cell company_count, rate_subjects
  end

  def designer_image_card
    card.metric_designer_card.field(:image)
  end

  view :thumbnail_with_vote do
    voo.hide! :thumbnail_link
    output [_render_vote, thumbnail]
  end

  view :latest_value do
    field_subformat(:latest_value)._render_concise
  end

  view :details do
    <<-HTML
        <div class="data-item show-with-details text-center">
          <span class="label label-metric">[[_l|Metric Details]]
          </span>
        </div>
    HTML
  end

  view :metric_details_link do
    <<-HTML
      <div class="contribution metric-details show-with-details text-center">
        <span class="label label-metric">[[_|Metric Details]]</span>
      </div>
    HTML
  end
end
