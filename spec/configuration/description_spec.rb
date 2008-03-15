require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Description do
  before { @configuration = RubyScreen::Configuration::Description.new }

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

  it "should be able to set shell executable" do
    @configuration.shell_executable = "zsh"
    @configuration.shell_executable.should eql("zsh")
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
