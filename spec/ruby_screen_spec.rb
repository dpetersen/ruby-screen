require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen do
  before do
    RubyScreen::Executer.stub!(:new) # don't want it to actually call Kernel#exec!
  end

  def process(arguments = [])
    RubyScreen.process(arguments)
  end

  it "should call RubyScreen::PreferencesLoader::load" do
    RubyScreen::PreferencesLoader.should_receive(:load).and_return({})
    process
  end

  it "should pass hash from PreferencesLoader and arguments to Configuration::Parser.parse" do
    preferences_hash = mock("mock preferences hash")
    RubyScreen::PreferencesLoader.stub!(:load).and_return(preferences_hash)

    arguments = mock("mock passed-in arguments")
    RubyScreen::Configuration::Parser.should_receive(:parse).with(arguments, preferences_hash)
    process(arguments)
  end

  it "should pass Configuration::Description to new Configuration::Executer" do
    RubyScreen::PreferencesLoader.stub!(:load)
    mock_configuration = mock("Mock Configuration::Description")
    RubyScreen::Configuration::Parser.stub!(:parse).and_return(mock_configuration)
    RubyScreen::Executer.should_receive(:new).with(mock_configuration)
    process
  end
end
