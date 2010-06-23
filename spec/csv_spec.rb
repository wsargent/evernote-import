require 'spec'
require "csv"

describe CSV do

  before(:each) do
    @importer = CSV.new
  end

  it "should import" do
    @importer.import
  end
  
end