require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen do
  def process(arguments = [])
    RubyScreen.process(arguments)
  end

  it "should call RubyScreen::PreferencesLoader::load" do
    RubyScreen::PreferencesLoader.should_receive(:load).and_return({})
    process
  end

  it "should pass hash from PreferencesLoader and arguments to ConfigurationGenerator and call generate" do
    preferences_hash = mock("mock preferences hash")
    RubyScreen::PreferencesLoader.stub!(:load).and_return(preferences_hash)

    arguments = mock("mock passed-in arguments")
    mock_generator = mock("mock Configuration::Generator")
    mock_generator.should_receive(:generate)
    RubyScreen::Configuration::Generator.should_receive(:new).with(arguments, preferences_hash).and_return(mock_generator)
    process(arguments)
  end
end
