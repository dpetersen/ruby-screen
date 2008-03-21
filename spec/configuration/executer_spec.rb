require File.dirname(__FILE__) + '/../spec_helper.rb'

class FileMock
  attr_reader :buffer

  def print(s)
    @buffer = s
  end
end

describe RubyScreen::Configuration::Executer do
  describe "#execute provided with Configuration::Description" do
    before do
      @configuration = mock("Configuration::Description mock")

      @configuration.stub!(:customizations).and_return(
        { :first => "custom", :second => "2" }
      )

      @configuration.stub!(:numbered_windows).and_return({
        0 => { "title" => "misc" },
        3 => { "title" => "three", "command" => "another command" },
        9 => { "command" => "final command" }
      })

      @configuration.stub!(:numberless_windows).and_return([
        { "title" => "second" },
        { "command" => "command-only window" }
      ])

      @configuration.stub!(:initial_directory).and_return("initial/directory")
    end

    it "should create a temporary file to store configuration and exec screen with it" do
      original_shell = ENV["SHELL"]
      ENV["SHELL"] = "/usr/bin/my_shell"
      original_home = ENV["HOME"]
      ENV["HOME"] = "/path/to/file"

      file_mock = FileMock.new
      File.should_receive(:open).with("/path/to/file/.ruby-screen.compiled_configuration", "w").and_yield(file_mock)

      Dir.should_receive(:chdir).with("initial/directory")
      Kernel.should_receive(:exec).with("screen -c /path/to/file/.ruby-screen.compiled_configuration")

      RubyScreen::Configuration::Executer.new(@configuration)

      file_mock.buffer.should_not be_nil
      file_mock.buffer.should match(/first custom/)
      file_mock.buffer.should match(/second 2/)

      s1 = "screen -t misc 0"
      s2 = "screen -t three 3 sh -c \"another command; /usr/bin/my_shell\""
      s3 = "screen 9 sh -c \"final command; /usr/bin/my_shell\""
      file_mock.buffer.should match(/#{s1}\s#{s2}\s#{s3}/)

      n1 = "screen -t second"
      n2 = "screen sh -c \"command-only window; /usr/bin/my_shell\""
      file_mock.buffer.should match(/#{n1}\s#{n2}/)

      ENV["SHELL"] = original_shell
      ENV["HOME"] = original_home
    end

    it "should not attempt to change directory when no initial directory is specified"
  end
end
