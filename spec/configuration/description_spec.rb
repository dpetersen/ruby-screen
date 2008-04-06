require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Description do
  before { @configuration = RubyScreen::Configuration::Description.new }

  it "should delegate #to_screen_configuration to Configuration::Generator" do
    configuration_string = "my configuration string"
    generator_mock = mock("mock Configuration::Generator")
    generator_mock.should_receive(:to_screen_configuration).and_return(configuration_string)
    RubyScreen::Configuration::Generator.should_receive(:new).and_return(generator_mock)
    @configuration.to_screen_configuration.should equal(configuration_string)
  end

  describe "customizations" do
    it "should be able to be added and retrieved" do
      @configuration.add_customization(:startup_message, "off")
      @configuration.add_customization(:foo, "bar")

      customizations = @configuration.customizations
      customizations[:startup_message].should eql("off")
      customizations[:foo].should eql("bar")
    end

    it "should overwrite customizations with the same name on subsequent addition" do
      @configuration.add_customization(:foo, "bar")
      @configuration.add_customization(:foo, "new value")
      @configuration.customizations[:foo].should eql("new value")
    end
  end

  it "should be able to set initial directory" do
    @configuration.initial_directory = "/my/dir/"
    @configuration.initial_directory.should eql("/my/dir/")
  end

  describe "windows" do
    it "should be able to add numberless windows" do
      @configuration.add_window(:title => "server window", :command => "script/server")
      numberless_windows = @configuration.numberless_windows
      numberless_windows.length.should eql(1)
      numberless_windows.first[:title].should eql("server window")
      numberless_windows.first[:command].should eql("script/server")
    end

    it "should be able to add numbered windows" do
      @configuration.add_window(:title => "My Window", :number => 1)
      numbered_windows = @configuration.numbered_windows
      numbered_windows.length.should eql(1)
      numbered_windows[1][:title].should eql("My Window")
    end
  end
end
