require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/InternalGroup.rb'
require '/script/lib/Auth.rb'
require '/script/lib/Constant.rb'
require 'logger'
require '/script/lib/SendMail.rb'
require '/script/lib/GsuiteUser.rb'
require '/script/lib/GsuiteGroup.rb'

log = Logger.new('/script/log/script.log')
log.progname = "add_internal_member"

mail = ErrorMail.new
gsuite_user = User.new
gsuite_group = GsuiteGroup.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize

excel = InternalGroup.new
user = User.new
groups = excel.get_group_list

groups.each{|group|
  excel_members = Array.new
  gsuite_members = Array.new

  excel_members = excel.get_members("#{group['英語名称']}")
  list = service.list_members("#{group['英語名称']}")
  list.members.each{|member| gsuite_members << member.email} unless list.members.nil?
  add_members = excel_members - gsuite_members

  add_members.each{|member|
    #ユーザーが削除された時のためにuser.check必要
    next if gsuite_user.check(member) == false && gsuite_group.check(member) == false
    begin
      add_member = Google::Apis::AdminDirectoryV1::Member.new(
        email: "#{member}",
        role: "#{MEMBER_ROLE}"
      )
      service.insert_member("#{group['英語名称']}",add_member)
      log.info("社内用グループにメンバーを追加しました。#{group['連絡先グループ名']}:#{member}")
    rescue => e
      log.fatal("社内用グループのユーザー追加で異常が発生しました。#{group['連絡先グループ名']}:#{member}")
      log.fatal("#{e}")
      mail.send("社内用グループのユーザー追加で異常が発生しました。#{group['連絡先グループ名']}:#{member}")
      next
    end
  }
}

