require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen do
  before do
    RubyScreen::Configuration::Executer.stub!(:new) # don't want it to actually call Kernel#exec!
  end

  def process(arguments = [])
    RubyScreen.process(arguments)
  end

  it "should call RubyScreen::PreferencesLoader::load" do
    RubyScreen::PreferencesLoader.should_receive(:load).and_return({})
    process
  end

  it "should pass hash from PreferencesLoader and arguments to Configuration::Parser and call parse" do
    preferences_hash = mock("mock preferences hash")
    RubyScreen::PreferencesLoader.stub!(:load).and_return(preferences_hash)

    arguments = mock("mock passed-in arguments")
    mock_parser = mock("mock Configuration::Parser")
    mock_parser.should_receive(:parse)
    RubyScreen::Configuration::Parser.should_receive(:new).with(arguments, preferences_hash).and_return(mock_parser)
    process(arguments)
  end

  it "should pass Configuration::Description to new Configuration::Executer" do
    RubyScreen::PreferencesLoader.stub!(:load)
    mock_parser = mock("Mock Configuration::Parser")
    mock_configuration = mock("Mock Configuration::Description")
    mock_parser.stub!(:parse).and_return(mock_configuration)
    RubyScreen::Configuration::Parser.stub!(:new).and_return(mock_parser)
    RubyScreen::Configuration::Executer.should_receive(:new).with(mock_configuration)
    process
  end
end
