require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe RubyScreen::Configuration::Parser::BlockProcessor do
  before { @mock_description = mock("Description") }

  after { RubyScreen::Configuration::Parser::BlockProcessor.new(@preferences_hash, @mock_description) }

  it "should call Description#add_window for any window configurations" do
    @mock_description.should_receive(:add_window).with({ "window1" => "settings1" }).ordered
    @mock_description.should_receive(:add_window).with({ "window2" => "settings2" }).ordered

    @preferences_hash = {
      "windows" => [
        { "window1" => "settings1" },
        { "window2" => "settings2" }
      ]
    }
  end

  it "should call Description#working_directory for any working_directory settings" do
    @mock_description = mock("Description")
    @mock_description.should_receive(:working_directory=).with("dir")

    @preferences_hash = { "working_directory" => "dir" }
  end

  it "should call Description#append_directory for any relative_directory settings" do
    @mock_description.should_receive(:append_directory).with("dir")

    @preferences_hash = { "relative_directory" => "dir" }
  end

  it "should call Description#add_customization for any abritrary settings" do
    @mock_description.should_receive(:add_customization).with("key1", "val1")
    @mock_description.should_receive(:add_customization).with("key2", "val2")

    @preferences_hash = { "key1" => "val1", "key2" => "val2" }
  end

  it "should change any boolean values to the strings 'on' and 'off'" do
    @mock_description.should_receive(:add_customization).with("true_thing", "on")
    @mock_description.should_receive(:add_customization).with("false_thing", "off")

    @preferences_hash = { "true_thing" => true, "false_thing" => false }
  end
end
