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
require 'json'

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
conferences = Hash.new

File.open("/script/etc/organization.json") do |file|
  conferences = JSON.load(file)
end

gsuite_organizations = Array.new
pagetoken = ""
loop do
  list = service.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
  list.groups.each{|group| gsuite_organizations << group.name}
  pagetoken = list.next_page_token
  break if pagetoken.nil?
end

#会議体グループ作成
conferences.each{|conference| 
  if gsuite_organizations.include?("#{HEAD}" + "#{conference['name']}") == false
    begin
      add_mirai = Google::Apis::AdminDirectoryV1::Group.new(
        email: "#{conference["email"]}",
        name: "#{HEAD}#{conference["name"]}",
        description: "#{conference["description"]}"
      )
      service.insert_group(add_mirai)
      group_setting = patch_service.get_group("#{conference["email"]}")
      unless  group_setting.who_can_post_message == 'ALL_IN_DOMAIN_CAN_POST' && group_setting.show_in_group_directory == true
        setting = Google::Apis::GroupssettingsV1::Groups.new(
          who_can_post_message: 'ALL_IN_DOMAIN_CAN_POST',
          show_in_group_directory: 'true'
        )
      patch_service.patch_group("#{conference["email"]}", setting)
      end
      log.info("#{conference['name']}グループを作成しました")
    rescue => e
      log.fatal("#{conference['name']}グループの作成に失敗しました。")
      log.fatal("#{e}")
      mail.send("#{conference['name']}グループの作成に失敗しました。")
    end
  end
}

my_emp = Group.new
organization = Array.new

excel_organizations = my_emp.get_group_list

#組織グループ作成
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
    next if group_setting.who_can_post_message == 'ANYONE_CAN_POST' && group_setting.show_in_group_directory == true
    begin
      setting = Google::Apis::GroupssettingsV1::Groups.new(
        who_can_post_message: 'ANYONE_CAN_POST',
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

