card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"

card_accessor :contribution_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"

view :missing do |args|
  _render_link args
end

def indirect_contributor_search_args
  [
    {:type_id=>ClaimID, :plus=>['topic',:link_to=>self.name]},
    {:type=>'source', :plus=>['topic',:link_to=>self.name]},
    {:type=>'analysis', :right=>self.name }
  ]
end

format :html do
  def view_caching?
    true
  end
end
