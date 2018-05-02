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
log.progname = "create_user"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

#ユーザー情報取得
#ユーザー数が500超えると見直し必要
#user_response = service.list_users(customer: 'my_customer', max_results: 500)

#ユーザー用の配列定義
#gsuite_user_email = Array.new

#ユーザーアドレスの取得
#user_response.users.each{|user| gsuite_user_email << user.primary_email}

gsuite_user_email = Array.new
pagetoken = ""
loop do
  list = service.list_users(customer: 'my_customer', max_results: 500,  page_token: "#{pagetoken}")
  list.users.each{|user| gsuite_user_email << user.primary_email}
  pagetoken = list.next_page_token
  break if pagetoken.nil?
end

#p employees = Employee.new
excel = Employee.new
employees = excel.get

#社員情報の社員数分処理を繰り返す
employees.each{|employee|
  next if gsuite_user_email.include?("#{employee['メールアドレス']}")

  begin
    add_user = Google::Apis::AdminDirectoryV1::User.new(
       primary_email: "#{employee['メールアドレス']}",
       name: {
          given_name: "#{employee['名']}",
          family_name: "#{employee['姓']}"
       },
       password: "#{PASSWORD}",
       change_password_at_next_login: 'true',
       org_unit_path: "#{ORGUNIT}",
       phones: [
         {
           value: "#{employee['会社貸与携帯番号']}",
           type: 'work'
         }
       ]
    )
    service.insert_user(add_user)
    log.info("ユーザーを作成しました。#{employee['姓']}#{employee['名']}:#{employee['メールアドレス']}")
  rescue => e
    log.fatal("ユーザー作成で異常が発生しました。#{employee['メールアドレス']}")
    log.fatal("#{e}")
    mail.send("ユーザー作成で異常が発生しました。#{employee['姓']}#{employee['名']}:#{employee['メールアドレス']}")
    next
  end
}
