require '/script/lib/excel.rb'
require '/script/lib/constant.rb'
require '/script/lib/log.rb'
require '/script/lib/mail.rb'

class Employee < Excel

  def initialize
    super(EMPLOYEE_FILE_NAME)
    begin
      @employees = Array.new
      @data.each{|row|
        next if row['メールアドレス'].nil?
        next unless row['兼務情報'].nil?
        row['メールアドレス'].gsub!(" ", "")
        (row['姓'] = row['名'] ; row['名'] = nil) if row['姓'].nil?
        row['名'] = 'メール' if row['名'].nil?
        @employees << row
      }
    rescue => exception
      Log.error("ユーザー情報のハッシュデータ作成処理でエラーが発生しました。")
      Log.error("#{exception}")
      SendMail.error("ユーザー情報のハッシュデータ作成処理でエラーが発生しました。\n#{exception}")
      exit
    end
  end  

  def get_users
    @employees
  end

end
