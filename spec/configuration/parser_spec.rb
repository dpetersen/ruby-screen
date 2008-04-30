require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Parser do
  before do
    @mock_configuration = mock("mock Configuration")
    RubyScreen::Configuration::Description.should_receive(:new).and_return(@mock_configuration)
  end

  def parse(hash, arguments = [])
    RubyScreen::Configuration::Parser.new(arguments, hash).parse
  end

  it "should return a Configuration::Description" do
    parse({}).should equal(@mock_configuration)
  end

  it "should handle a simple customization" do
    @mock_configuration.should_receive(:add_customization).with("startup_message", "off")
    parse({ "startup_message" => "off" })
  end

  it "should handle a customization that has a boolean value" do
    @mock_configuration.should_receive(:add_customization).with("first", "on")
    @mock_configuration.should_receive(:add_customization).with("second", "off")
    parse({ "first" => true, "second" => false})
  end

  it "should separate customizations and directory settings" do
    @mock_configuration.should_receive(:add_customization).with("startup_message", "off")
    @mock_configuration.should_receive(:working_directory=).with("/something")
    parse({ "startup_message" => "off", "working_directory" => "/something" })
  end

  it "should append nested relative_directory entries to the current working_directory" do
    @mock_configuration.should_receive(:working_directory=).with("something").ordered
    @mock_configuration.should_receive(:append_directory).with("else").ordered
    @mock_configuration.should_receive(:append_directory).with("final").ordered

    parse({
      "working_directory" => "something",
      "second" => {
        "relative_directory" => "else",
        "third" => {
          "relative_directory" => "final"
        }
      }
    }, ["second", "third"])
  end

  it "should handle windows" do
    first_window_mock = mock("first window mock")
    second_window_mock = mock("second window mock")
    @mock_configuration.should_receive(:add_window).with(first_window_mock)
    @mock_configuration.should_receive(:add_window).with(second_window_mock)
    parse({ "windows" => [ first_window_mock, second_window_mock ] })
  end

  it "should use arguments to merge in nested customizations" do
    @mock_configuration.should_receive(:add_customization).with("startup_message", "off").ordered
    @mock_configuration.should_receive(:add_customization).with("startup_message", "on").ordered
    @mock_configuration.should_receive(:add_customization).with("startup_message", "something else").ordered
    parse({
      "startup_message" => "off",
      "second" => {
        "startup_message" => "on",
        "third" => {
          "startup_message" => "something else"
        }
      }
    }, ["second", "third"])
  end

  describe "provided additional arguments that do not match nested configurations" do
    it "should join those arguments and call Configuration#append_directory with them" do
      @mock_configuration.should_receive(:append_directory).with("one").ordered
      @mock_configuration.should_receive(:append_directory).with("two").ordered
      parse({}, ["one", "two"])
    end
  end
end
