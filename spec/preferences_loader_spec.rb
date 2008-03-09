require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen::PreferencesLoader do
  it "should call YAML::load_file with default file path" do
    return_mock = mock("mock hashed YAML file")
    YAML.should_receive(:load_file).with("$HOME/.ruby-screen.yml").and_return(return_mock)
    RubyScreen::PreferencesLoader.load.should equal(return_mock)
  end
end
