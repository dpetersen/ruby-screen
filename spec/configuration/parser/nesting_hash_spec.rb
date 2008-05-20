require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe RubyScreen::Configuration::Parser::NestingHash do
  nested_preferences_hash = {
    "top" => "top_level",
    "nested1" => {
      "one" => 1,
      "nested2" => {
        "two" => 2,
        "nested3" => {
          "three" => 3
        }
      },
      "nested2.5" => {
        "nested4" => {
           "four" => 4
  }}}}

  duplicate_preferences_hash = {
    "first" => {
      "the_same" => {
        "second" => {
          "the_same" => {
  }}}}}

  before { nested_preferences_hash.extend(RubyScreen::Configuration::Parser::NestingHash) }

  it "should define a find_nested_key method when extended" do
    nested_preferences_hash.should respond_to(:find_nested_key)
  end

  describe "#find_nested_key" do
    it "should return nil when a search result isn't found" do
      nested_preferences_hash.find_nested_key("wang").should be_nil
    end

    it "should return an array of the hierarchy of hash keys that lead to the key that was searched for" do
      nested_preferences_hash.find_nested_key("nested2").should eql(["nested1", "nested2"])
      nested_preferences_hash.find_nested_key("nested4").should eql(["nested1", "nested2.5", "nested4"])
    end

    describe "given a hash with duplicate keys" do
      it "should raise a DuplicateKeyException" do
        lambda {
          duplicate_preferences_hash.extend(RubyScreen::Configuration::Parser::NestingHash)
        }.should raise_error(DuplicateKeyException)

      end

      it "should contain the name of the duplicated hash key in the exception" do
        begin
          duplicate_preferences_hash.extend(RubyScreen::Configuration::Parser::NestingHash)
        rescue DuplicateKeyException => e
          e.key.should eql("the_same")
        end
      end
    end
  end
end
