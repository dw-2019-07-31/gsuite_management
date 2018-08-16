require './lib/Excel.rb'
require './lib/Constant.rb'
require './lib/Log.rb'
require './lib/Mail.rb'

class Employee < Excel

  def initialize

    super(EMPLOYEE_FILE_NAME)
    begin
      @@employees = Array.new
      @data.each{|row|
        next if row['メールアドレス'].nil?
        next unless row['兼務情報'].nil?
        row['メールアドレス'].gsub!(" ", "")
        (row['姓'] = row['名'] ; row['名'] = nil) if row['姓'].nil?
        row['名'] = 'メール' if row['名'].nil?
        @@employees << row
      }
    rescue => exception
      Log.error("ユーザー情報のハッシュデータ作成処理でエラーが発生しました。")
      Log.error("#{exception}")
      SendMail.error("ユーザー情報のハッシュデータ作成処理でエラーが発生しました。\n#{exception}")
      exit
    end

  end  

  def get_users
    @@employees
  end

  def self.get_orgunit(employee)

    begin
      if employee['グループ名(英名略称)'] == "#{MANAGEMENT_GROUP}" || employee['親組織'] == "#{MANAGEMENT_GROUP}"
        orgunit  = "#{ORGUNIT_ICTG}"
      else
        orgunit = "#{ORGUNIT}"
      end
    rescue => exception
      Log.error("ユーザーの組織部門の取得でエラーが発生しました。")
      Log.error("#{exception}")
      SendMail.error("ユーザーの組織部門の取得でエラーが発生しました。\n#{exception}")
      exit
    end

    orgunit

  end

end
