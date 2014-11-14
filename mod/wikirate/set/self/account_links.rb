format :html do

  view :raw do |args|
    #ENGLISH
    links = []
    klasses = ''
    if Auth.signed_in?
      klasses = 'logged-in'
      links << link_to_page( Auth.current.name, nil, :id=>'my-card-link' )
      if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
        links << link_to( 'Invite', wagn_path('new/:signup'), :id=>'invite-a-friend-link' )
      end
      links << link_to( 'Log out', wagn_path('delete/:signin'), :id=>'signout-link' )
    else
      klasses = 'logged-out'
      if Card.new(:type_id=>Card::SignupID).ok? :create
        links << link_to( 'Join', wagn_path('new/:signup'), :id=>'signup-link', :class=>'button-primary' )
      end
      links << link_to( 'Log in', wagn_path(':signin'), :id=>'signin-link', :class=>'button-primary button-secondary' )
    end
    
    %{<span id="logging" class="#{klasses}">#{ links.join ' ' }</span>}
  end

end
  