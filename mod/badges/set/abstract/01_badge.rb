include_set Abstract::Certificate
include Comparable

format :html do
  delegate :badge_level, :threshold, to: :card

  view :description do
    "Awarded for #{valued_action} #{humanized_threshold}."
  end

  view :level do
    wrap_with :div, class: "badge-certificate" do
      certificate(badge_level)
    end
  end

  view :badge, tags: :unknown_ok do
    wrap_with :strong, card.name
  end

  view :notify do
    class_up "alert", "text-center"
    alert :success, true, false do
      [
        "<h4>#{certificate(badge_level)} #{card.name}</h4>",
        _render_description
      ]
    end
  end

  def humanized_threshold
    if threshold == 1
      "your first #{valued_object}"
    else
      "#{threshold} #{valued_object.pluralize}"
    end
  end
end

def flash_message
  format(:html)._render_notify
end

def threshold
  @threshold ||= badge_class.threshold badge_action, affinity_type, badge_key
end

def badge_level
  @level ||= badge_class.level badge_action, affinity_type, badge_key
end

def badge_level_index
  @level_index ||= badge_class.level_index badge_action, affinity_type, badge_key
end

def affinity_type
  nil
end

def badge_key
  @badge_key ||= codename.to_sym
end

def badge_action
  raise StandardError, "badge_action not overridden"
end

def badge_type
  raise StandardError, "badge_class not overridden"
end

def badge_class
  @badge_class ||=
    Card::Set::Type.const_get "#{badge_type.to_s.camelcase}::BadgeHierarchy"
end

def <=> other
  valid_to_compare? other
  level_order = compare_levels other
  return level_order unless level_order.zero?
  actions_order = compare_actions other
  return actions_order unless actions_order.zero?
  affinity_type == :general ? 1 : -1
end

def compare_actions other
  actions = badge_class.badge_actions
  actions.index(other.badge_action) <=> actions.index(badge_action)
end

def compare_levels other
  badge_level_index <=> other.badge_level_index
  # if badge_level == other.badge_level
  #   affinity_type == :general ? 1 : -1
  # else
  #   badge_level_index <=> other.badge_level_index
  # end
end

def valid_to_compare? other
  unless other.respond_to? :badge_class
    raise ArgumentError, "comparison with non-badge card #{other} failed"
  end
  if badge_class != other.badge_class
    raise ArgumentError, "comparison of different badge types failed"
  end
  true
end
