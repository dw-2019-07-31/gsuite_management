require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/ExternalGroup.rb'
require '/script/lib/Auth.rb'
require '/script/lib/Constant.rb'
require 'logger'
require '/script/lib/SendMail.rb'

log = Logger.new('/script/log/script.log')
log.progname = "create_external_group"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

patch_service = Google::Apis::GroupssettingsV1::GroupssettingsService.new
patch_service.client_options.application_name = APPLICATION_NAME
patch_service.authorization = gsuite.setting_authorize

gsuite_groups = Array.new
pagetoken = ""
loop do
  list = service.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
  list.groups.each{|group| gsuite_groups << group.name}
  pagetoken = list.next_page_token
  break if pagetoken.nil?
end

excel = ExternalGroup.new

groups = excel.get_group_list

groups.each{|group|
  if gsuite_groups.index("#{group['連絡先グループ名']}").nil?
     begin
       add_org = Google::Apis::AdminDirectoryV1::Group.new(
         email: "#{group['英語名称']}",
         name: "#{group['連絡先グループ名']}",
         description: "#{EXTERNAL_DESCRIPTION}"
       )  
       service.insert_group(add_org)
       log.info("外部公開用グループを作成しました。#{group['連絡先グループ名']}")
     rescue => e
       log.fatal("外部公開用グループ作成で異常が発生しました。#{group['連絡先グループ名']}")
       log.fatal("#{e}")
       mail.send("外部公開用グループ作成で異常が発生しました。")
       next
     end

     group_setting = patch_service.get_group("#{group['英語名称']}")
     next if group_setting.who_can_post_message == 'ANYONE_CAN_POST' && group_setting.show_in_group_directory == 'true'
     begin
       setting = Google::Apis::GroupssettingsV1::Groups.new(
         who_can_post_message: 'ANYONE_CAN_POST',
         show_in_group_directory: 'true'
       )
       patch_service.patch_group("#{group['英語名称']}", setting)
       log.info("グループの設定を変更しました。#{group['連絡先グループ名']}")
     rescue => e
       log.fatal("グループの設定変更に失敗しました。#{group['連絡先グループ名']}")
       log.fatal("#{e}")
       mail.send("グループの設定変更に失敗しました。#{group['連絡先グループ名']}")
       next
     end
  end

}

