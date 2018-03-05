require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/Auth.rb'
require '/script/lib/Group.rb'
require '/script/lib/Constant.rb'
require 'logger'
require '/script/lib/SendMail.rb'

log = Logger.new('/script/log/script.log')
log.progname = "delete_group"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

excel = Group.new
groups = Array.new

group_list = service.list_groups(customer: 'my_customer')

group_list.groups.each{|group| groups << group.email}

groups.each{|group|
  members = Array.new
  list = service.list_members("#{group}")
  list.members.each{|member| members << member.email} unless list.members.nil?

  if members.empty?
    begin
      service.delete_group("#{group}")
      log.info("グループを削除しました。#{group}")
    rescue => e
      log.fatal("グループの削除で異常が発生しました。#{group}")
      log.fatal("#{e}")
      mail.send("グループの削除で異常が発生しました。#{group}")
      next
    end
  end
}
