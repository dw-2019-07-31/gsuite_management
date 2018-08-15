require 'roo'
require './lib/Constant.rb'
require 'singleton'

class Excel

  include Singleton

  def initialize(files_name)

    files_name.each{|file_name|
      book = Roo::Spreadsheet.open(file_name)
      @sheet = book.sheet('Sheet1')

      header = nil
      @data = Array.new
      @sheet.each{|row|
        #row[2].gsub!(" ","") unless file_name == "#{EMPLOYEE_FILE_NAME}"
        # ヘッダーが読み込み済みで、データの先頭が # だったら読み飛ばす
        next if (not header.nil?) && row[0] =~ /^#/

        if header.nil?
          header = row unless row[0] =~ /^#/
        else
          array = [header,row].transpose
          hash = Hash[*array.flatten]
          @data << hash
        end
      }
    }
  end

end
