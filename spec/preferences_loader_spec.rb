require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen::PreferencesLoader do
  it "should call YAML::load_file with default file path" do
    original_home = ENV["HOME"]
    ENV["HOME"] = "/my/home/path"

    return_mock = mock("mock hashed YAML file")
    YAML.should_receive(:load_file).with("/my/home/path/.ruby-screen.yml").and_return(return_mock)
    RubyScreen::PreferencesLoader.load.should equal(return_mock)

    ENV["HOME"] = original_home
  end

  it "should display a helpful error message when the default file cannot be loaded" do
    Kernel.should_receive(:abort).with(an_instance_of(String))
    YAML.should_receive(:load_file).and_raise("not want!")

    RubyScreen::PreferencesLoader.load
  end
end
