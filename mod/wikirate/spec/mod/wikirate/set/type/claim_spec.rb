# -*- encoding : utf-8 -*-

describe Card::Set::Type::Claim do
  before do
    login_as 'joe_user' 
  end
  def create_page iUrl=nil
      url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card::Env.params[:sourcebox] = 'true'
    sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
    Card::Env.params[:sourcebox] = 'false'

    sourcepage
  end

  it "should handle too long claim" do
    card = Card.new(   :type=>"Claim", :name=>"2"*101 )
    card.should_not be_valid
    card.errors.should have_key :claim
    card.errors[:claim].first.should=="is too long (100 character maximum)"
  end
  
  it "should handle normal claim creation" do
    #create the testing webpage first
    claim_name = "2"*100
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'

    #test single source
    card = Card.new :type=>"Claim", :name=>claim_name ,:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}    
    card.should be_valid

    card = Card.new :type=>"Claim", :name=>claim_name ,:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]\r\n[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}
    card.should be_valid

  end

  it "should handle claim modification" do
    #create the testing webpage first
    claim_name = "2"*100
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'

    #test single source
    card = Card.create! :type=>"Claim", :name=>claim_name ,:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}    

    card = Card[card.name]
    card.name = 'the alley cat is awesome'
    card.save!

    # card.should be_valid
  end
  it "should require +source card " do
    fake_pagename = "Page-1"
    url = "[[#{fake_pagename}]]"

    # nth here
    card = Card.new(   :type=>"Claim", :name=>"2"*100)
    card.should_not be_valid
    card.errors.should have_key :source
    card.errors[:source].include?("is empty").should==true
    #without type
    card = Card.new(   :type=>"Claim", :name=>"2"*100,:subcards=>{ '+source' => {:content=> url}})
    card.should_not be_valid
    card.errors.should have_key :source
    card.errors[:source].include?("#{fake_pagename} does not exist").should ==true

    #with a non exisiting url in any webpage
    card = Card.new(   :type=>"Claim", :name=>"2"*100 ,:subcards=>{ '+source' => {:content=> url,:type_id=>Card::PointerID}})
    card.should_not be_valid
    card.errors.should have_key :source
    card.errors[:source].include?("#{fake_pagename} does not exist").should ==true


    page = create_page
    card = Card.new(   :type=>"Claim", :name=>"2"*100,:subcards=>{ '+source' => {:content=> "[[Home]]",:type_id=>Card::PointerID}})
    card.should_not be_valid
    card.errors.should have_key :source
    puts card.errors[:source]
    card.errors[:source].include?("Home is not a valid Source Page").should ==true
  end
  
  context "voting" do
    before do
      @card = create_claim "another voting claim"
    end
    
    it 'default vote count is 0' do
      expect(@card.vote_count.to_i).to eq 0
    end
    describe "#add_upvote" do
      it "increases upvote count" do
        uvc = @card.upvote_count.to_i
        @card.add_upvote
        expect(@card.upvote_count.to_i).to eq uvc+1
      end
      it "increases vote count" do
        vc = @card.vote_count.to_i
        @card.add_upvote
        expect(@card.vote_count.to_i).to eq vc+1
      end
    end
    describe "#delete_upvote" do
      it "decreases upvote count" do
        uvc = @card.upvote_count.to_i
        @card.delete_upvote
        expect(@card.upvote_count.to_i).to eq uvc-1
      end
      it "decreases vote count" do
        vc = @card.vote_count.to_i
        @card.delete_upvote
        expect(@card.vote_count.to_i).to eq vc-1
      end
    end
    
    describe "#add_downvote" do
      it "increases downvote count" do
        dvc = @card.downvote_count.to_i
        @card.add_downvote
        expect(@card.downvote_count.to_i).to eq dvc+1
      end
      it "decreases vote count" do
        vc = @card.vote_count.to_i
        @card.add_downvote
        expect(@card.vote_count.to_i).to eq vc-1
      end
    end
    describe "#delete_downvote" do
      it "decreases downvote count" do
        dvc = @card.downvote_count.to_i
        @card.delete_downvote
        expect(@card.downvote_count.to_i).to eq dvc-1
      end
      it "increases vote count" do
        vc = @card.vote_count.to_i
        @card.delete_downvote
        expect(@card.vote_count.to_i).to eq vc+1
      end
    end   
  end
end

