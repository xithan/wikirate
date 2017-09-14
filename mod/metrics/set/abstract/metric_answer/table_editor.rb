format :html do
  view :table_form, cache: :never, perms: :update, tags: :unknown_ok do
    voo.editor = :inline_nests
    with_nest_mode :edit do
      relative_card_form :create, "main-success" => "REDIRECT",
                                  class: "new-value-form",
                                  success: { id: card.contextual_record_name,
                                             soft_redirect: true,
                                             view: :new_answer_success } do
        render_haml :new_form
      end
    end
  end

  def new_buttons
    button_formgroup do
      [
        submit_button(disable_with: "Adding..."),
        button_tag("Close", class: "_form_close_button")
      ]
    end
  end

  def answer_form_hidden_tags
    tags = {}
    tags["card[name]"] = card.name
    # tags["card[subcards][+metric][content]"] = card.metric
    tags["card[type_id]"] =
      card.metric_card.relationship? ? RelationshipAnswerID : MetricValueID
    tags["card[subcards][+source][content]"] = source if source.present?
    hidden_tags tags
  end

  def view_template_path view
    super view, __FILE__
  end
end
