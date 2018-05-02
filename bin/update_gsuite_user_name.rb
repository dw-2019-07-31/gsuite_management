require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/Auth.rb'
require 'logger'
require '/script/lib/Employee.rb'
require '/script/lib/Constant.rb'

log = Logger.new('/script/log/script.log')
log.progname = "update_user_name"

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

#ユーザー情報取得
#ユーザー数が500超えると見直し必要
#user_response = service.list_users(customer: 'my_customer', max_results: 500)

#ユーザー用の配列定義
#gsuite_user = Array.new
#data = Array.new

#ユーザーアドレスの取得
#user_response.users.each{|user|
#  hash = { 'mail' => user.primary_email, 'family_name' => user.name.family_name}
#  gsuite_user << hash
#}

gsuite_user = Array.new
pagetoken = ""
loop do
  list = service.list_users(customer: 'my_customer', max_results: 500,  page_token: "#{pagetoken}")
  list.users.each{|user| gsuite_user << { 'mail' => user.primary_email, 'family_name' => user.name.family_name}}
  pagetoken = list.next_page_token
  break if pagetoken.nil?
end

#p employees = Employee.new
excel = Employee.new
employees = excel.get

#社員情報の社員数分処理を繰り返す
employees.each{|employee|
  gsuite_user.each{|user|
    next unless "#{user['mail']}" == "#{employee['メールアドレス']}"
    next if "#{employee['グループ名(英名略称)']}".empty?
    next if "#{user['family_name']}" =~ /^#{employee['グループ名(英名略称)']}_/
    begin
      update_user = Google::Apis::AdminDirectoryV1::User.new(
      name: {
       family_name: "#{employee['グループ名(英名略称)']}_#{employee['姓']}"
      }
      )
      service.update_user("#{employee['メールアドレス']}",update_user)
      log.info("ユーザーの名前更新が正常に終了しました。#{employee['メールアドレス']}:#{employee['姓']}#{employee['名']}")
    rescue => e
      log.fatal("ユーザーの名前更新で異常が発生しました。#{employee['メールアドレス']}:#{employee['姓']}#{employee['名']}")
      log.fatal("#{e}")
    end
  }
}
