describe Answer do
  let(:answer) { described_class.find_by_answer_id answer_id }
  let(:metric) { "Joe User+researched" }
  let(:answer_name) { "#{metric}+Apple_Inc+2013" }
  let(:answer_id) { Card.fetch_id answer_name }

  describe "seeded metric answer table" do
    it "has correct count" do
      expect(described_class.count)
        .to eq Card.search(type_id: Card::MetricValueID, return: :count)
    end

    context "random example" do
      it "exists" do
        is_expected.to be_instance_of(described_class)
      end
      it "has company_id" do
        expect(answer.company_id).to eq Card.fetch_id("Apple Inc")
      end
      it "has year" do
        expect(answer.year).to eq 2013
      end
      it "has metric_id" do
        expect(answer.metric_id).to eq Card.fetch_id("Joe User+researched")
      end
      it "has metric_type_id" do
        expect(answer.metric_type_id).to eq Card.fetch_id("researched")
      end
      it "has designer_id" do
        expect(answer.designer_id).to eq Card.fetch_id("Joe User")
      end
      it "has value" do
        expect(answer.value).to eq "13"
      end
      it "has metric_name" do
        expect(answer.metric_name).to eq "Joe User+researched"
      end
      it "has company_name" do
        expect(answer.company_name).to eq "Apple_Inc"
      end
    end
  end

  # describe "#fetch_by" do
  #   it "handles company id" do
  #     expect(described_class.find_by)
  #   end
  # end

  describe "delete" do
    it "removes entry" do
      answer_id
      delete answer_name
      expect(answer).to be_nil
    end
  end

  describe "updates" do
    before do
      # fetch answer_id before the change
      answer_id
    end
    it "updates company" do
      update answer_name, name: "Joe User+researched+Samsung+2013"
      expect(answer.company_id).to eq Card.fetch_id("Samsung")
      expect(answer.company_name).to eq "Samsung"
    end

    it "updates metric" do
      update answer_name, name: "Joe User+researched number 2+Apple_Inc+2013"
      expect(answer.metric_id).to eq Card.fetch_id("Joe User+researched number 2")
      expect(answer.metric_name).to eq "Joe User+researched number 2"
    end

    it "updates year" do
      update answer_name, name: "Joe User+researched+Apple_Inc+1999"
      expect(answer.year).to eq 1999
    end

    it "updates value" do
      update "#{answer_name}+value", content: "85"
      expect(answer.value).to eq "85"
    end

    it "updates designer" do
      update "Joe User", name: "Jimmy User"
    end

    it "updates metric type" do
      update [metric, :metric_type], content: "[[Score]]"
      expect(answer.metric_type_id).to eq Card.fetch_id("score")
    end

    it "updates policy" do
      create_or_update [metric, :research_policy], content: "[[Community Assessed]]"
      expect(answer.policy_id).to eq Card.fetch_id("Community Assessed")
    end

    it "updates updated_at" do
    end
  end

  describe "fetch" do
    described_class.fetch company_id: Card.fetch_id("Apple Inc")
  end
end
