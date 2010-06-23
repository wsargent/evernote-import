require 'importer'
require 'htmlentities'
require 'date'

class Text

  attr_reader :importer

  def initialize
    @importer = Importer.new
  end

  def import
    importer.connect
    notebook = importer.find_notebook
    coder = HTMLEntities.new

    (2003..2008).each do |year|
      my_file = File.expand_path("/Users/wsargent/dropbox/diary/#{year}.txt")

      current_date = DateTime.civil(year, 1, 1)
      diary = {}

      File.open(my_file).each do |line|        
        begin
          current_date = DateTime.strptime(line, "%D")
        rescue ArgumentError => e
        end
        
        unless diary[current_date]
          diary[current_date] = []
        end

        good_line = coder.encode(line.chomp, :named)
        diary[current_date] << good_line
      end

      diary.each do |date, lines|
        content = wrap_content(lines)
        title = date.strftime("%D")
        #puts "title = #{title}, content = #{content}"
        created_timestamp = to_time(date).to_i * 1000 # must use milliseconds
        importer.create_note(title, content, created_timestamp, notebook)
      end
    end
  end

  def wrap_content(lines)
    lines.join("<br/>") || ''
  end

  def to_time(date)
     ::Time.local(date.year, date.month, date.day)
  end

end
