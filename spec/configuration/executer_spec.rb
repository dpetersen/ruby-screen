require File.dirname(__FILE__) + '/../spec_helper.rb'

class FileMock
  attr_reader :buffer

  def print(s)
    @buffer = s
  end
end

describe RubyScreen::Configuration::Executer do
  describe "provided a working nested configuration" do
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

      @file_mock = FileMock.new
      File.stub!(:open).and_yield(@file_mock)
      Dir.stub!(:chdir)
      Kernel.stub!(:exec)

      @original_shell = ENV["SHELL"]
      ENV["SHELL"] = "/usr/bin/my_shell"
      @original_home = ENV["HOME"]
      ENV["HOME"] = "/path/to/file"
    end

    after do
      ENV["SHELL"] = @original_shell
      ENV["HOME"] = @original_home
    end

    describe "#execute" do
      after { RubyScreen::Configuration::Executer.new(@description) }

      it "should open a file to store the compiled screen configuration" do
        File.should_receive(:open).with("/path/to/file/.ruby-screen.compiled_configuration", "w").and_yield(@file_mock)
      end

      it "should attempt to change directory to correct initial directory" do
        Dir.should_receive(:chdir).with("initial/directory")
      end

      it "should write compiled configuration to the opened file" do
        @file_mock.should_receive(:print).with(an_instance_of(String))
      end

      it "should exec screen, passing the path to the compiled configuration" do
        Kernel.should_receive(:exec).with("screen -c /path/to/file/.ruby-screen.compiled_configuration")
      end
    end

    describe "compiled configuration" do
      before { RubyScreen::Configuration::Executer.new(@description) }

      it "should include top level customizations" do
        @file_mock.buffer.should match(/first custom/)
        @file_mock.buffer.should match(/second 2/)
      end

      it "should include numbered windows" do
        s1 = "screen -t misc 0"
        s2 = "screen -t three 3 sh -c \"another command; /usr/bin/my_shell\""
        s3 = "screen 9 sh -c \"final command; /usr/bin/my_shell\""
        @file_mock.buffer.should match(/#{s1}\s#{s2}\s#{s3}/)
      end

      it "should include numberless windows" do
        n1 = "screen -t second"
        n2 = "screen sh -c \"command-only window; /usr/bin/my_shell\""
        @file_mock.buffer.should match(/#{n1}\s#{n2}/)
      end
    end
  end

  describe "provided a configuration with an invalid initial directory" do
    it "should not attempt to change directory when no initial directory is specified"
  end
end
