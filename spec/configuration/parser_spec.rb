require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Parser do
  before do
    @mock_arguments = mock("Arguments")
    @mock_preferences_hash = mock("Preferences Hash")

    @mock_iterator = mock("Iterator")
    @mock_iterator.stub!(:each_applicable_configuration_block)
    @mock_iterator.stub!(:arguments).and_return([])
    RubyScreen::Configuration::Parser::Iterator.stub!(:new).and_return(@mock_iterator)

    @mock_description = mock("Description")
    RubyScreen::Configuration::Description.stub!(:new).and_return(@mock_description)
  end

  after { RubyScreen::Configuration::Parser.parse(@mock_arguments, @mock_preferences_hash) }

  it "should instantiate a new Iterator with the arguments and preferences_hash" do
    RubyScreen::Configuration::Parser::Iterator.should_receive(:new).with(@mock_arguments, @mock_preferences_hash).and_return(@mock_iterator)
  end

  it "should instantiate a new Description" do
    RubyScreen::Configuration::Description.should_receive(:new)
  end

  it "should call the Iterator#each_applicable_configuration_block and pass the yielded block to a BlockProcessor" do
    mock_configuration_block = mock("Configuration Block")
    @mock_iterator.should_receive(:each_applicable_configuration_block).and_yield(mock_configuration_block)
    RubyScreen::Configuration::Parser::BlockProcessor.should_receive(:new).with(mock_configuration_block, @mock_description)
  end

  it "should call Description#append_directory for each additional argument" do
    @mock_iterator.stub!(:arguments).and_return(["first", "second"])
    @mock_description.should_receive(:append_directory).with("first").ordered
    @mock_description.should_receive(:append_directory).with("second").ordered
  end
end
