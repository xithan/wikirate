# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::MetricConnoisseur do
  it_behaves_like "badge card", :metric_connoisseur, :gold, 25
end
