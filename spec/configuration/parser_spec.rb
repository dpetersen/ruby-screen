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

  it "should separate customizations and special settings" do
    @mock_configuration.should_receive(:add_customization).with("startup_message", "off")
    @mock_configuration.should_receive(:initial_directory=).with("~/something")
    parse({ "startup_message" => "off", "initial_directory" => "~/something" })
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
    it "should append those arguments to initial_directory" do
      @mock_configuration.should_receive(:initial_directory).ordered.and_return(nil)
      @mock_configuration.should_receive(:initial_directory=).with("one/two").ordered
      parse({}, ["one", "two"])
    end

    it "should add slash prefix to additional arguments when initial_directory is defined without a trailling slash" do
      @mock_configuration.should_receive(:initial_directory).ordered.and_return("~/something")
      @mock_configuration.should_receive(:initial_directory=).with("~/something/one/two").ordered
      parse({}, ["one", "two"])
    end

    it "should not add slash prefix to additional arguments when initial_directory is defined with a trailing slash" do
      @mock_configuration.should_receive(:initial_directory).ordered.and_return("~/something/")
      @mock_configuration.should_receive(:initial_directory=).with("~/something/one/two").ordered
      parse({}, ["one", "two"])
    end
  end
end
