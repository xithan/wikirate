format :html do
  def google_analytics_head_javascript
    if ga_key = Card.setting("*google analytics key") #fixme.  escape this?
      %{
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{ga_key}']);
          _gaq.push(['_setPageGroup', '1', '#{root.card.type_name}']);
          _gaq.push(['_trackPageview']);
          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
      }
    end
  end

  view :raw do |args|
    result = super(args)
    if !request
      user_agent = request.user_agent
      if user_agent && ( user_agent=="Facebot" || user_agent.include?("facebookexternalhit/1.1"))
        result += subformat(Card.fetch("#{Env.params["id"]}+facebook_meta"))._render_core
      end
    end
    result
  end
end
   
      