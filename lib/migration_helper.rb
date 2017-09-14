module MigrationHelper
  BATCH_SIZE = 500
  def rename old_name, new_name
    cap_old  = old_name.capitalize
    cap_new  = new_name.capitalize
    down_old = old_name.downcase
    down_new = new_name.downcase
    Rails.logger.info "Change name from '#{cap_old}' to '#{cap_new}'"
    Card[cap_old].update_attributes! name: cap_new,
                                     update_referers: true,
                                     silent_change: true
    # don't change claim/note names
    ids = Card.search name: ["match", down_old], not: { type: "Note" }, return: :id
    Rails.logger.info "Update #{ids.size} cards with '#{cap_old}' in the name"
    count = 0
    ids.each do |id|
      name = Card.where(id: id).pluck(:name).first
      Rails.logger.info "Updating name: #{name} (#{id})"
      next unless name !~ /\+/   # no junctions
      new_name = name.gsub(cap_old, cap_new).gsub(down_old, down_new)
      count += 1
      Card.find(id).update_attributes! name: new_name,
                                       update_referers: true,
                                       silent_change: true
      if count > BATCH_SIZE
        Card::Cache.reset_all
        count = 0
      end
    end

    double_check = []
    ids = Card.search(content: ["match", down_old], return: :id)
    Rails.logger.info "Update #{ids.size} cards with '#{cap_old}' in the content"
    ids.each do |id|
      card = Card.fetch(id, skip_modules: true)
      Rails.logger.info "Updating content: #{card.name} (#{id})"
      new_content = card.content.gsub(cap_old, cap_new).gsub(down_old, down_new)
      card.update_column :db_content, new_content
      if card.type_id == Card::BasicID || card.type_id == Card::PlainTextID
        double_check << "[[#{card.name}]]"
      end
    end
    Card.create! name: "used #{cap_old} in content",
                 type: "pointer",
                 content: double_check.join("\n")
  end
end
