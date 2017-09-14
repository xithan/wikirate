def imported?
  answer.imported
end

def checked?
  answer.checkers.present? || answer.check_requester.present?
end

def commented?
  disc = fetch trait: :discussion
  disc && disc.content.present?
end

format :html do
  view :flags do
    output [checked_value_flag, comment_flag, imported_flag]
  end

  view :small_flags do
    output do
      [:checked_value, :comment, :imported].map do |flag_name|
        flag = send "#{flag_name}_flag"
        "<small>#{flag}</small>"
      end
    end
  end

  def checked_value_flag
    return "" unless card.checked?
    nest card.field(:checked_by), view: :icon, class: "fa-lg margin-left-10"
  end

  def comment_flag
    return "" unless card.commented?
    icon_tag "commenting", title: "Has comments", class: "fa-lg margin-left-10"
  end

  def imported_flag
    return "" unless card.imported?
    icon_tag "import", library: :glyphicon, title: "imported"
  end
end
