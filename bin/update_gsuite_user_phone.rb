require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/Auth.rb'
require 'logger'
require '/script/lib/Employee.rb'
require '/script/lib/Constant.rb'
require '/script/lib/SendMail.rb'

log = Logger.new('/script/log/script.log')
log.progname = "update_user_phone"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

#ユーザー情報取得
#ユーザー数が500超えると見直し必要
user_response = service.list_users(customer: 'my_customer', max_results: 500)

#ユーザー用の配列定義
gsuite_user = Array.new
data = Array.new

#ユーザーアドレスの取得
user_response.users.each{|user|
  if user.phones.nil?
    hash = { 'mail' => user.primary_email, 'phone'=> ""}
  else
    user.phones.each{|phone|
    hash = { 'mail' => user.primary_email, 'phone'=> phone['value']}
    }
  end
gsuite_user << hash
}

#p employees = Employee.new
excel = Employee.new
employees = excel.get

#社員情報の社員数分処理を繰り返す
employees.each{|employee|
  gsuite_user.each{|user|
    
  begin
    if "#{user['mail']}" == "#{employee['メールアドレス']}"
      if "#{user['phone']}" != "#{employee['会社貸与携帯番号']}"
      update_user = Google::Apis::AdminDirectoryV1::User.new(
      phones: [{
       value: "#{employee['会社貸与携帯番号']}",
       type: 'work'
      }]
      )
      service.update_user("#{employee['メールアドレス']}",update_user)
      log.info("電話番号の更新が正常に終了しました。#{employee['メールアドレス']}:#{employee['会社貸与携帯番号']}")
      end
    end
  rescue => e
    log.fatal("電話番号の更新で異常が発生しました。#{employee['メールアドレス']}")
    log.fatal("#{e}")
    mail.send("電話番号の更新で異常が発生しました。#{employee['メールアドレス']}")
  end
  }
}
