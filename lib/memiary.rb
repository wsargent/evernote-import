
require 'importer'
require 'feed_tools'

class Memiary

  attr_reader :importer

  def initialize()
    @importer = Importer.new
  end

  def import_evernote    

    rss_url = "file:///Users/wsargent/work/evernote-import/memiary.xml"

    begin
      importer.connect

      notebook = importer.find_notebook

      rss_feed = parse_rss(rss_url)
      rss_feed.items.each do |item|
        title = item.time.strftime("%D")
        created_timestamp = item.time.to_i * 1000 # must use milliseconds
        importer.create_note(title, item.content, created_timestamp, notebook)
      end
    rescue Evernote::EDAM::Error::EDAMUserException => e
      puts "user exception = #{e.inspect}"
    rescue Evernote::EDAM::Error::EDAMSystemException => e
      puts "exception = #{e.inspect}"
    end
  end

  def parse_rss(rss_url)    
    feed = FeedTools::Feed.open(rss_url)
    feed
  end

end
