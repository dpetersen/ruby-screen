require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen::Executer do
  describe "provided a working nested configuration" do
    before do
      @description = mock("mock Configuration::Description")
      @description.stub!(:to_screen_configuration)
      @description.stub!(:initial_directory)

      @file_mock = mock("mock File")
      @file_mock.stub!(:print)
      File.stub!(:open).and_yield(@file_mock)
      Dir.stub!(:chdir)
      Kernel.stub!(:exec)

      @original_home = ENV["HOME"]
      ENV["HOME"] = "/path/to/file"
    end

    after do
      ENV["HOME"] = @original_home
    end

    describe "#execute" do
      after { RubyScreen::Executer.new(@description) }

      it "should open a file to store the compiled screen configuration" do
        File.should_receive(:open).with("/path/to/file/.ruby-screen.compiled_configuration", "w").and_yield(@file_mock)
      end

      it "should attempt to change directory to correct initial directory" do
        @description.should_receive(:initial_directory).twice.and_return("initial/directory/path")
        Dir.should_receive(:chdir).with("initial/directory/path")
      end

      it "should write compiled configuration from description to the opened file" do
        @description.should_receive(:to_screen_configuration).and_return("my configuration string")
        @file_mock.should_receive(:print).with("my configuration string")
      end

      it "should exec screen, passing the path to the compiled configuration" do
        Kernel.should_receive(:exec).with("screen -c /path/to/file/.ruby-screen.compiled_configuration")
      end
    end
  end

  describe "provided a configuration with an invalid initial directory" do
    it "should not attempt to change directory when no initial directory is specified"
  end
end
