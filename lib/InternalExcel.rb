require 'roo'
require '/script/lib/Constant.rb'

class InternalExcel

#  INTERNAL_FILE_NAME = '/mnt/gsuite/close/ADIV/ICTG/01_プロジェクト/13期/メールサーバー見直し/20_APItest/グループ_test.xlsx'

  def initialize
    book = Roo::Spreadsheet.open(INTERNAL_FILE_NAME)
    @sheet = book.sheet('Sheet1')

    header = nil
    @data = Array.new
    @sheet.each{|row|
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
