require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
# require 'google/apis/Vault_V1'
require '/script/lib/vault_v1.rb'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require '/script/lib/Auth_Vault.rb'
require 'logger'
require '/script/lib/Constant_Vault.rb'

log = Logger.new('/script/log/vault.log')
log.progname = "vault_get_matters"

#オブジェクト作成
gsuite = Auth.new

# service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
begin
    service = Google::Apis::VaultV1::VaultService.new()
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = gsuite.vault_authorize

    #matterのlistを取ってくる
    mymatters = Array.new
    apiresponse = service.list_matters(page_size: 100)
    apiresponse.matters.each{|matter| mymatters << { 'matterid' => matter.matter_id, 'name' => matter.name, 'state' => matter.state} }

    #ログファイルにlistを書き出し
    mymatters.each{|currentmatter|
        log.info("#{currentmatter['matterid']} : #{currentmatter['name']} : #{currentmatter['state']}")
    }
rescue => e
    log.fatal("vault_matter取得処理で異常が発生しました。")
    log.fatal("#{e}")
end

# gsuite_user = Array.new
# pagetoken = ""
# loop do
#   list = service.list_users(customer: 'my_customer', max_results: 500,  page_token: "#{pagetoken}")
#   list.users.each{|user| gsuite_user << { 'mail' => user.primary_email, 'family_name' => user.name.family_name}}
#   pagetoken = list.next_page_token
#   break if pagetoken.nil?
# end

# excel = Employee.new
# employees = excel.get

# #社員情報の社員数分処理を繰り返す
# employees.each{|employee|
#   gsuite_user.each{|user|
#     next unless "#{user['mail']}" == "#{employee['メールアドレス']}"
#     next if "#{employee['グループ名(英名略称)']}".empty?
#     next if "#{user['family_name']}" =~ /^#{employee['グループ名(英名略称)']}_/
#     begin
#       update_user = Google::Apis::AdminDirectoryV1::User.new(
#       name: {
#        family_name: "#{employee['グループ名(英名略称)']}_#{employee['姓']}"
#       }
#       )
#       service.update_user("#{employee['メールアドレス']}",update_user)
#       log.info("ユーザーの名前更新が正常に終了しました。#{employee['メールアドレス']}:#{employee['姓']}#{employee['名']}")
#     rescue => e
#       log.fatal("ユーザーの名前更新で異常が発生しました。#{employee['メールアドレス']}:#{employee['姓']}#{employee['名']}")
#       log.fatal("#{e}")
#     end
#   }
# }

