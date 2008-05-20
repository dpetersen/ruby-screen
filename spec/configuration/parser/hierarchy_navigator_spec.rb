require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe RubyScreen::Configuration::Parser::HierarchyNavigator do

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
        }
      }
    }
  }

  def navigator(argument, preferences_hash)
    RubyScreen::Configuration::Parser::HierarchyNavigator.new(argument, preferences_hash).hierarchy
  end

  it "should raise error message when there are configurations with duplicated names" do
    duplicate_preferences_hash = {
      "first" => {
        "the_same" => {
          "second" => {
            "the_same" => {
    }}}}}

    Kernel.should_receive(:abort).with /the_same/
    navigator([], duplicate_preferences_hash)
  end

  describe "given no nested configurations" do
    it "should return an empty array" do
      navigator([], {}).should eql([])
    end
  end

  describe "given a nested configuration without an argument pointing to them" do
    it "should return an empty array" do
      navigator([], nested_preferences_hash).should eql([])
    end
  end

  describe "given a nested configuration with an argument pointing to them" do
    it "should return an array with the nesting hierarchy down to the argument" do
      navigator(["nested2"], nested_preferences_hash).should eql(["nested1", "nested2"])
      navigator(["nested4"], nested_preferences_hash).should eql(["nested1", "nested2.5", "nested4"])
    end
  end
end
