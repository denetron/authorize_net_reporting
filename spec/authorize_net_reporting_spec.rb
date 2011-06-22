require 'spec_helper'
describe AuthorizeNetReporting do
  let(:test_mode) do
     #TEST API LOGIN: 3vk59E5BgM - API KEY:4c8FeAW7ebq5U733
    { :mode => "test", :login=>"3vk59E5BgM", :key => "4c8FeAW7ebq5U733" }
  end
  
  let(:live_mode) do
    { :mode => "live", :key=>"key", :login => "login" }
  end  
  context "missing requirements" do
    it "should raise exception" do
      lambda { AuthorizeNetReporting.new }.should raise_error(ArgumentError)
    end
  end
  describe "API URL in live mode" do
    subject { AuthorizeNetReporting.new(live_mode) }
    it "should be live url" do
      subject.api_url.should eql(AuthorizeNetReporting::LIVE_URL)
    end
  end
  
  before(:each) do
    @authorize_net_reporting = AuthorizeNetReporting.new(test_mode)
  end  
  
  describe "API URL in test mode" do 
    it 'should be test url' do
      @authorize_net_reporting.api_url.should eql(AuthorizeNetReporting::TEST_URL)
    end
  end

  describe "settled_batch_list" do
    context "when there are not batches settled" do
      it "should raise Standard Error 'no records found'" do
        lambda { @authorize_net_reporting.settled_batch_list }.should raise_error(StandardError)
      end
    end
    context "when there are settled batches" do
      it "should return batches" do
        batches = @authorize_net_reporting.settled_batch_list({:first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20"})
        batches.size.should eql(4)    
      end
    end
    context "when request include statistics" do
      it "should return statistis as an Array" do 
        batches = @authorize_net_reporting.settled_batch_list({:first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20", :include_statistics => true})
        batches.first.statistics.should be_an_instance_of(Array)
      end  
    end  
  end
  
  describe "batch_statistics" do
    it "should return an array statistics for given batch" do
      @authorize_net_reporting.batch_statistics(1049686).statistics.should be_an_instance_of(Array)
    end
  end
  
  describe "transactions_list" do
    it "should return all transactions in a specified batch" do
      transactions = @authorize_net_reporting.transaction_list(1049686)
      transactions.size.should eql(4)
    end
  end  

  describe "unsettled_transaction_list" do
    it "should return unsettled transactions" do
      transactions = @authorize_net_reporting.unsettled_transaction_list
      transactions.should be_an_instance_of(Array)
    end  
  end  
  
  describe "transaction_details" do
    it "should return transaction if transaction_exists" do
      transaction = @authorize_net_reporting.transaction_details(2157585857)
      transaction.should be_an_instance_of(AuthorizeNetTransaction)
    end
    it "should raise StandardError 'record not found' if transaction doesn't exist" do
      lambda { @authorize_net_reporting.transaction_details(0) }.should raise_error(StandardError)
    end
  end
end
