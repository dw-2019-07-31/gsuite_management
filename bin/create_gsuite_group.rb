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
log.progname = "create_group"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

patch_service = Google::Apis::GroupssettingsV1::GroupssettingsService.new
patch_service.client_options.application_name = APPLICATION_NAME
patch_service.authorization = gsuite.setting_authorize

#グループ情報取得
organization_response = service.list_groups(customer: 'my_customer')

#GSuiteにグループアドレスがない場合、処理通る
if organization_response.groups.nil?
  #全社共通・幹部会議・決定報告会議グループ作成
  add_determination = Google::Apis::AdminDirectoryV1::Group.new(
    email: "#{DETERMINATION}",
    name: "#{HEAD}決定報告会議",
    description: "#{DETERMINATION_DESCRIPTION}"
  )
  service.insert_group(add_determination)

  add_executive = Google::Apis::AdminDirectoryV1::Group.new(
    email: "#{EXECUTIVE}",
    name: "#{HEAD}幹部会議",
    description: "#{EXECUTIVE_DESCRIPTION}"
  )
  service.insert_group(add_executive)

  add_all = Google::Apis::AdminDirectoryV1::Group.new(
    email: "#{ALL}",
    name: "#{HEAD}全社共通",
    description: "#{ALL_DESCRIPTION}"
  )
  service.insert_group(add_all)
end

#グループ情報再取得
organization_response = service.list_groups(customer: 'my_customer')

#グループ用の配列定義
gsuite_organizations = Array.new

#グループ情報からグループ名を取得
organization_response.groups.each{|group| gsuite_organizations << group.name}

my_emp = Group.new
organization = Array.new

excel_organizations = my_emp.get_group_list

excel_organizations.each{|organization|
  unless gsuite_organizations.include?("#{HEAD}" + "#{organization}")
    begin
      add_org = Google::Apis::AdminDirectoryV1::Group.new(
        email: "#{organization}#{DOMAIN}",
        name: "#{HEAD}#{organization}",
        description: "#{ORGANIZATION_DESCRIPTION}"
      )  
      service.insert_group(add_org)
      log.info("グループを作成しました。#{organization}")
    rescue => e
      log.fatal("グループ作成で異常が発生しました。#{organization}")
      log.fatal("#{e}")
      mail.send("グループ作成で異常が発生しました。#{organization}")
      next
    end

    group_setting = patch_service.get_group("#{organization}#{DOMAIN}")
    next if group_setting.who_can_post_message == 'ALL_IN_DOMAIN_CAN_POST' && group_setting.show_in_group_directory == 'true'
    begin
      setting = Google::Apis::GroupssettingsV1::Groups.new(
        who_can_post_message: 'ALL_IN_DOMAIN_CAN_POST',
        show_in_group_directory: 'true'
      )
      patch_service.patch_group("#{organization}#{DOMAIN}", setting)
      log.info("グループの設定を変更しました。#{organization}")
    rescue => e
      log.fatal("グループの設定変更に失敗しました。#{organization}")
      log.fatal("#{e}")
      mail.send("グループの設定変更に失敗しました。#{organization}")
      next
    end

  end
}

