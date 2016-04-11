# -*- encoding : utf-8 -*-

# the metric in the test database:
# Card::Metric.create name: 'Jedi+deadliness+Joe User',
#                     type: :score,
#                     formula: '{{Jedi+deadliness}}/10'
describe Card::Set::MetricType::Score do
  describe 'score card' do
    subject { Card[:score] }
    it { is_expected.to be_truthy }
    it 'has codename' do
      expect(subject.codename).to eq 'score'
    end
    it 'has type "metric type"' do
      expect(subject.type_id).to eq Card['metric type'].id
    end
  end

  before do
    @name = 'Jedi+deadliness+Joe User'
  end
  let(:metric) { Card[@name] }
  describe '#metric_type' do
    subject { metric.metric_type }
    it { is_expected.to eq 'Score' }
  end
  describe '#metric_type_codename' do
    subject { metric.metric_type_codename }
    it { is_expected.to eq :score }
  end
  describe '#metric_designer' do
    subject { metric.metric_designer }
    it { is_expected.to eq 'Jedi' }
  end
  describe '#metric_designer_card' do
    subject { metric.metric_designer_card }
    it { is_expected.to eq Card['Jedi'] }
  end
  describe '#metric_title' do
    subject { metric.metric_title }
    it { is_expected.to eq 'deadliness' }
  end
  describe '#metric_title_card' do
    subject { metric.metric_title_card }
    it { is_expected.to eq Card['deadliness'] }
  end
  describe '#question_card' do
    subject { metric.question_card.name }
    it { is_expected.to eq 'Jedi+deadliness+Joe User+Question'}
  end
  describe '#value_type' do
    subject { metric.value_type }
    it { is_expected.to eq 'Number' }
  end
  describe '#categorical?' do
    subject { metric.categorical? }
    it { is_expected.to be_falsey }
  end
  describe '#researched?' do
    subject { metric.researched? }
    it { is_expected.to be_falsey }
  end
  describe '#scored?' do
    subject { metric.scored? }
    it { is_expected.to be_truthy }
  end
  describe '#scorer' do
    subject { metric.scorer }
    it { is_expected.to eq 'Joe User' }
  end
  describe '#scorer_card' do
    subject { metric.scorer_card }
    it { is_expected.to eq Card['Joe User'] }
  end
  describe '#basic_metric' do
    subject { metric.basic_metric }
    it { is_expected.to eq 'Jedi+deadliness' }
  end

  def score_value company='Samsung', year='2014'
    score_value_card(company, year).content
  end

  def score_value_card company='Samsung', year='2014'
    Card["Joe User+#{@metric_title}+Big Brother+#{company}+#{year}+value"]
  end

  describe 'score for numerical metric' do
    context 'when created with formula' do
      before do
        @metric_title = 'score2'
        Card::Auth.as_bot do
          @metric = create_metric(
            name: "Joe User+#{@metric_title}+Big Brother", type: :score,
            formula: "{{Joe User+#{@metric_title}}}*2"
          )
        end
      end
      it 'creates score values' do
        expect(score_value).to eq('10')
        expect(score_value 'Samsung', '2015').to eq('4')
        expect(score_value 'Sony_Corporation').to eq('4')
        expect(score_value_card 'Death_Star', '1977').to be_falsey
      end

      context 'and formula changes' do
        def update_formula formula
          Card::Auth.as_bot do
            @metric.formula_card.update_attributes! content: formula
          end
        end
        it 'updates existing rating value' do
          update_formula '{{Joe User+score2}}*3'
          expect(score_value).to eq '15'
        end
        # it 'fails if basic metric is not used in formula' do
        #   #update_formula '{{Jedi+deadliness}}'
        #   pending 'not checked yet'
        # end
      end

      context 'and a input metric value is missing' do
        it "doesn't create score value" do
          expect(score_value_card 'Death Star', '1977').to be_falsey
        end
        it "creates score value if missing value is added" do
          Card::Auth.as_bot do
            Card['Joe User+score2'].create_value company: 'Death Star',
                                                 year: '1977',
                                                 value: '2',
                                                 source: get_a_sample_source
          end
          expect(score_value 'Death Star', '1977').to eq('4')
        end
      end

      context 'and input metric value changes' do
        it 'updates score value' do
          Card['Joe User+score2+Samsung+2014+value'].update_attributes! content: '1'
          expect(score_value).to eq '2'
        end
        it 'removes score value that lost input metric value' do
          Card::Auth.as_bot do
            Card['Joe User+score2+Samsung+2014+value'].delete
          end
          expect(score_value_card).to be_falsey
        end
      end
    end

    context 'when created without formula' do
      before do
        Card::Auth.as_bot do
          @metric_title = 'score1'
          @metric = create_metric name: "Joe User+#{@metric_title}+Big Brother",
                                  type: :score
        end
      end
      it 'has basic metric as formula' do
        expect(Card["#{@metric.name}+formula"].content)
          .to eq '{{Joe User+score1}}'
      end
      it 'creates score values if formula updated' do
        Card::Auth.as_bot do
          @metric.formula_card.update_attributes!(
            type_id: Card::PlainTextID,
            content: '{{Joe User+score1}}*2'
          )
        end
        expect(score_value).to eq('20')
        expect(score_value 'Samsung', '2015').to eq('10')
        expect(score_value 'Sony_Corporation').to eq('2')
      end
    end
  end

  context 'if original value changed' do
    before do
      Card['Jedi+deadliness+Death Star+1977+value'].update_attributes!(
        content: 40
      )
    end
    it 'updates scored valued' do
      expect(Card['Jedi+deadliness+Joe User+Death Star+1977+value'].content)
        .to eq '4'
    end

    it 'updates dependent ratings' do
      expect(Card['Jedi+darkness rating+Death Star+1977+value'].content)
        .to eq '6.4'
    end
  end
end