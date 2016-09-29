format :html do
  def default_sign_up_args args
    super
    args[:link_opts][:class] = "btn btn-highlight"
    args[:link_text] = "Join"
  end

  def default_sign_in_args args
    super
    args[:link_opts][:class] = "btn btn-default"
    args[:link_text] = "Log in"
  end

  def default_sign_out_args args
    super
    args[:link_text] = "Log out"
  end
end