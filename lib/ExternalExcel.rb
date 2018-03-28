require 'roo'
require '/script/lib/Constant.rb'

class ExternalExcel

  def initialize
    book = Roo::Spreadsheet.open(EXTERNAL_SHOP_FILE_NAME)
    @sheet = book.sheet('Sheet1')

    header = nil
    @data = Array.new
    @sheet.each{|row|
      row[2].gsub!(" ","")
      next if (not header.nil?) && row[0] =~ /^#/

      if header.nil?
        header = row
      else
        array = [header,row].transpose
        hash = Hash[*array.flatten]
        @data << hash
      end
    }

    book = Roo::Spreadsheet.open(EXTERNAL_PUBLIC_FILE_NAME)
    @sheet = book.sheet('Sheet1')

    header = nil
    @sheet.each{|row|
      row[2].gsub!(" ","")
      next if (not header.nil?) && row[0] =~ /^#/

      if header.nil?
        header = row
      else
        array = [header,row].transpose
        hash = Hash[*array.flatten]
        @data << hash
      end
    }
  end

end
