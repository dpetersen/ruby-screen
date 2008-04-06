require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Generator, "#to_screen_configuration" do
  before do
    @description = mock("Configuration::Description mock")

    @description.stub!(:customizations).and_return(
      { :first => "custom", :second => "2" }
    )

    @description.stub!(:numbered_windows).and_return({
      0 => { "title" => "misc" },
      3 => { "title" => "three", "command" => "another command" },
      9 => { "command" => "final command" }
    })

    @description.stub!(:numberless_windows).and_return([
      { "title" => "second" },
      { "command" => "command-only window" }
    ])

    @description.stub!(:initial_directory).and_return("initial/directory")

    @original_shell = ENV["SHELL"]
    ENV["SHELL"] = "/usr/bin/my_shell"

    @configuration_string = RubyScreen::Configuration::Generator.new(@description).to_screen_configuration

    ENV["SHELL"] = @original_shell
  end

  it "should include top level customizations" do
    @configuration_string.should match(/first custom/)
    @configuration_string.should match(/second 2/)
  end

  it "should include numbered windows" do
    s1 = "screen -t misc 0"
    s2 = "screen -t three 3 sh -c \"another command; /usr/bin/my_shell\""
    s3 = "screen 9 sh -c \"final command; /usr/bin/my_shell\""
    @configuration_string.should match(/#{s1}\s#{s2}\s#{s3}/)
  end

  it "should include numberless windows" do
    n1 = "screen -t second"
    n2 = "screen sh -c \"command-only window; /usr/bin/my_shell\""
    @configuration_string.should match(/#{n1}\s#{n2}/)
  end
end
