require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe RubyScreen::Configuration::Parser::Iterator do
  def capture_yield(arguments, hash)
    @iterator = RubyScreen::Configuration::Parser::Iterator.new(arguments, hash)
    @yielded = []
    @iterator.each_applicable_configuration_block { |b| @yielded << b }
  end

  describe "with no nested configurations" do
    it "should return the top level items in the hash" do
      capture_yield([], { "one" => 1 })

      @yielded.length.should eql(1)
      @yielded[0].should == { "one" => 1 }
    end
  end

  describe "with nested configurations" do
    it "should not yield any nested configurations that the arguments do not specify" do
      capture_yield([], { "one" => 1, "nested" => { "two" => 2 } })

      @yielded.length.should eql(1)
      @yielded[0].should == { "one" => 1 }
    end

    it "should yield nested configuration hashes one at a time as dictated by the arguments" do
      capture_yield(["nested"], { "one" => 1, "nested" => { "two" => 2 } })

      @yielded.length.should eql(2)
      @yielded[0].should == { "one" => 1 }
      @yielded[1].should == { "two" => 2 }
    end
  end

  describe "with additional arguments" do
    it "should contain only those arguments in the arguments array after iteration is complete" do
      capture_yield(["nested", "add1", "add2"], { "one" => 1, "nested" => { "two" => 2 } })

      @iterator.arguments.length.should eql(2)
      @iterator.arguments[0].should eql("add1")
      @iterator.arguments[1].should eql("add2")
    end
  end
end
