require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen::Executer do
  before do
    @description = mock("mock Configuration::Description")
    @description.stub!(:to_screen_configuration)
    @description.stub!(:initial_directory)

    @file_mock = mock("mock File")
    @file_mock.stub!(:print)
    File.stub!(:open).and_yield(@file_mock)
    File.stub!(:exists?).and_return(true)
    File.stub!(:directory?).and_return(true)
    Dir.stub!(:chdir)
    Dir.stub!(:tmpdir).and_return("/tmp")
    Kernel.stub!(:exec)
  end

  after { RubyScreen::Executer.new(@description) }

  describe "provided a valid Configuration::Description" do
    describe "#initialize" do
      it "should request the file systems' temporary directory" do
        Dir.should_receive(:tmpdir).any_number_of_times.and_return("/tmp")
      end

      it "should open a file to store the compiled screen configuration" do
        File.should_receive(:open).with("/tmp/.ruby-screen.compiled_configuration", "w").and_yield(@file_mock)
      end

      it "should check that the initial_directory from the Description is valid" do
        @description.stub!(:initial_directory).and_return("initial/directory/path")
        File.should_receive(:exists?).with("initial/directory/path").and_return(true)
        File.should_receive(:directory?).with("initial/directory/path").and_return(true)
      end

      it "should attempt to change directory to correct initial directory" do
        @description.should_receive(:initial_directory).any_number_of_times.and_return("initial/directory/path")
        Dir.should_receive(:chdir).with("initial/directory/path")
      end

      it "should write compiled configuration from description to the opened file" do
        @description.should_receive(:to_screen_configuration).and_return("my configuration string")
        @file_mock.should_receive(:print).with("my configuration string")
      end

      it "should exec screen, passing the path to the compiled configuration" do
        Kernel.should_receive(:exec).with("screen -c /tmp/.ruby-screen.compiled_configuration")
      end
    end
  end

  describe "provided a Configuration::Description with an invalid initial directory" do
    before do
      @description.stub!(:initial_directory).and_return("initial/directory/path")
      File.stub!(:exists?).and_return(false)
    end

    it "should abort with an error" do
      Kernel.should_receive(:abort).with(/initial\/directory\/path/)
    end
  end
end
