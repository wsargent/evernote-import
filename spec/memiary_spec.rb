require 'spec'
require 'memiary'

describe Memiary do
  before(:each) do
    @main = Memiary.new
  end

  it "should import" do
    @main.import_evernote
  end
  
end

