require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen::PreferencesLoader do
  before do
    @original_home = ENV["HOME"]
    ENV["HOME"] = "/my/home/path"

    YAML.stub!(:load)
    erb = mock("ERB Mock")
    erb.stub!(:result)
    ERB.stub!(:new).and_return(erb)
    IO.stub!(:read)
  end

  after { ENV["HOME"] = @original_home }

  it "should call IO#read with the default file path" do
    IO.should_receive(:read).with("/my/home/path/.ruby-screen.yml")
    RubyScreen::PreferencesLoader.load
  end

  it "should display a helpful error message when the file cannot be loaded" do
    lambda {
      Kernel.should_receive(:abort).with(/\.ruby-screen\.yml/)
      IO.stub!(:read).and_raise("not want!")
      RubyScreen::PreferencesLoader.load
    }.should_not raise_error
  end

  it "should pass output from IO#read through ERB#new, and call #result" do
    read_results = mock("read results")
    IO.stub!(:read).and_return(read_results)
    erb_mock = mock("ERB Mock")
    erb_mock.should_receive(:result)
    ERB.should_receive(:new).and_return(erb_mock)
    RubyScreen::PreferencesLoader.load
  end

  it "should pass return value from erb results to YAML#load" do
    erb_mock = mock("ERB Mock")
    erb_mock.stub!(:result).and_return("return from erb")
    ERB.stub!(:new).and_return(erb_mock)
    YAML.should_receive(:load).with("return from erb").and_return("return from YAML")
    RubyScreen::PreferencesLoader.load.should eql("return from YAML")
  end
end
