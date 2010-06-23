require 'fastercsv'
require 'htmlentities'
          
require 'importer'

class CSV

  attr_reader :importer

  def initialize
    @importer = Importer.new
  end

  def import
    coder = HTMLEntities.new
            
    my_file = File.expand_path("/Users/wsargent/work/evernote-import/joes_goals.csv")

    diary = {}

    FasterCSV.foreach(my_file, { :headers => true }) do |row|
      mark_date = row['MARK_DATE']
      unless mark_date
        next
      end

      begin
        current_date = DateTime.strptime(mark_date, "%m/%d/%Y")
      rescue ArgumentError => e
        puts "mark date = " + mark_date + "e = " + e.inspect
      end

      unless current_date
        raise "no current date found in #{row.inspect}"
      end

      unless diary[current_date]
        diary[current_date] = []
      end

      good_line = coder.encode("#{row['GOAL_NAME']}: #{row['LOG'].chomp}", :named)
      diary[current_date] << good_line
    end

    sorted_diary = diary.sort_by { |k,v| k }


    importer.connect
    notebook = importer.find_notebook
    sorted_diary.each do |date, lines|
      content = wrap_content(lines)
      title = date.strftime("%D")
      created_timestamp = to_time(date).to_i * 1000 # must use milliseconds
      puts "created_timestamp: title = #{title}, content = #{content}"
      importer.create_note(title, content, created_timestamp, notebook)
    end

  end

  def wrap_content(lines)
    lines.join("<br/>") || ''
  end

  def to_time(date)
    ::Time.local(date.year, date.month, date.day)
  end


end