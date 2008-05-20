require File.dirname(__FILE__) + '/../spec_helper.rb'

describe RubyScreen::Configuration::Parser do
  before do
    @preferences_hash = { "preferences" => "hash" }
    @preferences_hash.stub!(:find_nested_key).and_return(["first", "second"])

    @mock_iterator = mock("Iterator")
    @mock_iterator.stub!(:each_applicable_configuration_block)
    RubyScreen::Configuration::Parser::Iterator.stub!(:new).and_return(@mock_iterator)

    @mock_description = mock("Description")
    @mock_description.stub!(:append_directory)
    RubyScreen::Configuration::Description.stub!(:new).and_return(@mock_description)
  end

  after do
    arguments = ["first_argument", "second_argument", "third_argument"]
    RubyScreen::Configuration::Parser.parse(arguments, @preferences_hash)
  end

  it "should extend the preferences_hash with the NestingHash module" do
    @preferences_hash.should_receive(:extend).with(RubyScreen::Configuration::Parser::NestingHash)
  end

  it "should call #find_nested_key on the preferences_hash with the first argument" do
    @preferences_hash.should_receive(:find_nested_key).with("first_argument")
  end

  it "should instantiate a new Iterator with the path returned by #find_nested_key and preferences_hash" do
    RubyScreen::Configuration::Parser::Iterator.should_receive(:new).with(["first", "second"], @preferences_hash).and_return(@mock_iterator)
  end

  it "should set the configuration path to a blank array if no key is found" do
    @preferences_hash.stub!(:find_nested_key).and_return(nil)
    RubyScreen::Configuration::Parser::Iterator.should_receive(:new).with([], @preferences_hash).and_return(@mock_iterator)
  end

   it "should catch a DuplicateKeyException from the preferences_hash and abort if so, naming the offending key" do
    @preferences_hash.should_receive(:extend).and_raise(DuplicateKeyException.new("problem_key"))
    Kernel.should_receive(:abort).with /problem_key/
   end

  it "should instantiate a new Description" do
    RubyScreen::Configuration::Description.should_receive(:new).and_return(@mock_description)
  end

  it "should call the Iterator#each_applicable_configuration_block and pass the yielded block to a BlockProcessor" do
    mock_configuration_block = mock("Configuration Block")
    @mock_iterator.should_receive(:each_applicable_configuration_block).and_yield(mock_configuration_block)
    RubyScreen::Configuration::Parser::BlockProcessor.should_receive(:new).with(mock_configuration_block, @mock_description)
  end

  # Oi, what a cluster.  Can't specify global ordering, and to do this perfectly I'd have to mock a ton.
  it "should call Description#append_directory for each additional argument only after main configuration has been parsed" do
    @iterated = false
    @second_arg_called = false
    @third_arg_called = false

    @mock_iterator.should_receive(:each_applicable_configuration_block) { @iterated = true }
    @mock_description.should_receive(:append_directory).twice { |arg|
      fail "Called out of order, additional arguments added before configuration processed!" unless @iterated

      if arg == "second_argument" && !@second_arg_called && !@third_arg_called
        @second_arg_called = true
      elsif arg == "third_argument" && @second_arg_called && !@third_arg_called
        @third_arg_called = true
      else
        fail "Called out of order, with arg #{arg}"
      end
    }
  end
end
