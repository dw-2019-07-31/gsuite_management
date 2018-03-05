require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/Auth.rb'
require '/script/lib/InternalGroup.rb'
require '/script/lib/Constant.rb'
require 'logger'
require '/script/lib/SendMail.rb'

log = Logger.new('/script/log/script.log')
log.progname = "delete_internal_member"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

excel = InternalGroup.new

groups = Array.new
list = service.list_groups(customer: 'my_customer')
list.groups.each{|group| groups << group.email unless group.name =~ /^DW_/ || group.description == 'External Office'}

groups.each{|group|
  excel_members = Array.new
  gsuite_members = Array.new

  excel_members = excel.get_members("#{group}")

  list = service.list_members("#{group}")
  list.members.each{|member| gsuite_members << member.email} unless list.members.nil?

  delete_members = gsuite_members - excel_members

  delete_members.each{|member|
    begin
      service.delete_member("#{group}", "#{member}")
      log.info("社内用グループからメンバーを削除しました。#{group}:#{member}")
    rescue => e
      log.fatal("社内用グループのメンバー削除で異常が発生しました。#{group}:#{member}")
      log.fatal("#{e}")
      mail.send("社内用グループのメンバー削除で異常が発生しました。#{group}:#{member}")
      next
    end
  }
}
