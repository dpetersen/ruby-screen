require File.dirname(__FILE__) + '/spec_helper.rb'

describe RubyScreen do
  it "should call RubyScreen::PreferencesLoader::load" do
    RubyScreen::PreferencesLoader.should_receive(:load).and_return({})
    RubyScreen.process([])
  end
end
