RSpec.describe Card::Chart::RangeChart::Buckets, "bucket calculation" do
  MIN = 582_603
  MAX = 5_613_573

  def buckets lower, upper
    buck = Class.new
    buck.extend Card::Chart::RangeChart::Buckets
    buck.instance_eval { @buckets = 10 }
    buck.define_singleton_method(:max) { upper }
    buck.define_singleton_method(:min) { lower }
    buck.calculate_buckets
    buck
  end

  def bucket_ranges min, max
    ranges =  [[be <= min, be > min]]
    ranges += [[be > min, be > min]] * 8
    ranges << [be > min, be_between(max, max + 100).inclusive]
    ranges
  end

  describe "#each_bucket" do
    it "creates 10 buckets" do
      expect { |probe| buckets(MIN, MAX).each_bucket(&probe) }.to yield_control.exactly(10).times
    end

    it "calculates correctly" do
      expect { |probe| buckets(MIN, MAX).each_bucket(&probe) }
        .to yield_successive_args(*bucket_ranges(MIN, MAX))
    end

    context "negative values" do
      MIN = -500_000
      MAX = 50_600_000

      it "calculates correctly" do
        expect { |probe| buckets(MIN, MAX).each_bucket(&probe) }
          .to yield_successive_args(*bucket_ranges(MIN, MAX))
      end
    end
  end
end
