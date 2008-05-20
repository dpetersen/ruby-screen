require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Parser do
  before do
    @mock_preferences_hash = mock("Preferences Hash")

    @mock_hierarchy_navigator = mock("HierarchyNavigator")
    @mock_hierarchy_navigator.stub!(:hierarchy).and_return(["first", "second"])
    RubyScreen::Configuration::Parser::HierarchyNavigator.stub!(:new).and_return(@mock_hierarchy_navigator)

    @mock_iterator = mock("Iterator")
    @mock_iterator.stub!(:each_applicable_configuration_block)
    RubyScreen::Configuration::Parser::Iterator.stub!(:new).and_return(@mock_iterator)

    @mock_description = mock("Description")
    @mock_description.stub!(:append_directory)
    RubyScreen::Configuration::Description.stub!(:new).and_return(@mock_description)
  end

  after do
    arguments = ["first_argument", "second_argument", "third_argument"]
    RubyScreen::Configuration::Parser.parse(arguments, @mock_preferences_hash)
  end

  it "should instantiate a new HierarchyNavigator with the first argument and the preferences hash" do
    RubyScreen::Configuration::Parser::HierarchyNavigator.should_receive(:new).with(["first_argument"], @mock_preferences_hash).and_return(@mock_hierarchy_navigator)
  end

  it "should instantiate a new Iterator with the path returned by HierarchyNavigator and preferences_hash" do
    RubyScreen::Configuration::Parser::Iterator.should_receive(:new).with(["first", "second"], @mock_preferences_hash).and_return(@mock_iterator)
  end

  it "should instantiate a new Description" do
    RubyScreen::Configuration::Description.should_receive(:new).and_return(@mock_description)
  end

  it "should call the Iterator#each_applicable_configuration_block and pass the yielded block to a BlockProcessor" do
    mock_configuration_block = mock("Configuration Block")
    @mock_iterator.should_receive(:each_applicable_configuration_block).and_yield(mock_configuration_block)
    RubyScreen::Configuration::Parser::BlockProcessor.should_receive(:new).with(mock_configuration_block, @mock_description)
  end

  it "should call Description#append_directory for each additional argument" do
    @mock_description.should_receive(:append_directory).with("second_argument").ordered
    @mock_description.should_receive(:append_directory).with("third_argument").ordered
  end
end
