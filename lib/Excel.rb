require 'roo'
require '/script/lib/Constant.rb'

class Excel

  def initialize

    book = Roo::Spreadsheet.open(EMPLOYEE_FILE_NAME)
    @sheet = book.sheet('Sheet1')

    header = nil
    @data = Array.new
    @sheet.each{|row|
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
  end

end
