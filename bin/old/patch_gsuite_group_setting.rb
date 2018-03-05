require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/Auth.rb'
require 'logger'
require '/script/lib/Group.rb'
require '/script/lib/Constant.rb'
require '/script/lib/SendMail.rb'

log = Logger.new('/script/log/script.log')
log.progname = "patch_group_setting"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

patch_service = Google::Apis::GroupssettingsV1::GroupssettingsService.new
patch_service.client_options.application_name = APPLICATION_NAME
patch_service.authorization = gsuite.setting_authorize

groups_email = Array.new

#グループ情報取得
group_list = service.list_groups(customer: 'my_customer')

group_list.groups.each{|group| groups_email << group.email}

groups_email.each{|email|
  group_setting = patch_service.get_group(email)
  next if group_setting.show_in_group_directory == 'true'
  begin
    setting = Google::Apis::GroupssettingsV1::Groups.new(
      show_in_group_directory: 'true'
    )
    patch_service.patch_group(email, setting)
    log.info("グループの設定を変更しました。#{email}")
  rescue => e
    log.fatal("グループの設定変更に失敗しました。#{email}")
    log.fatal("#{e}")
    mail.send("グループの設定変更に失敗しました。#{email}")
    next
  end
}
