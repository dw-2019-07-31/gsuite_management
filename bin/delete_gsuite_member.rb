require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'google/apis/groupssettings_v1'
require '/script/lib/Group.rb'
require '/script/lib/Auth.rb'
require '/script/lib/Constant.rb'
require 'logger'
require '/script/lib/SendMail.rb'
require 'json'

log = Logger.new('/script/log/script.log')
log.progname = "delete_member"

mail = ErrorMail.new

#オブジェクト作成
gsuite = Auth.new

service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
service.client_options.application_name = APPLICATION_NAME
service.authorization = gsuite.authorize
conference = Array.new

File.open("/script/etc/organization.json") do |file|
  hash = JSON.load(file)
  hash.each{|value| conference << value.values}
  conference.flatten!
end

excel = Group.new
groups = Array.new

groups = Array.new
list = service.list_groups(customer: 'my_customer')
list.groups.each{|group| groups << {'email' => group.email, 'name' => group.name} if group.name =~ /^DW_/}

groups.each{|group|
  excel_members = Array.new
  gsuite_members = Array.new
  
  if group['email'] == "#{ALL}"
    excel_members = excel.get_all
  elsif conference.include?("#{group['email']}") == true
    meeting_structure_name = excel.get_meeting_header_name("#{group['name']}")
    puts meeting_structure_name
    excel_members = excel.get_meeting_structure("#{meeting_structure_name}")
  else
    excel_members = excel.get_members_recurse("#{group['email'].sub(/@dadway.com/, "").upcase}") 
  end

  list = service.list_members("#{group['email']}")
  list.members.each{|member| gsuite_members << member.email} unless list.members.nil?

  excel_members == nil ? delete_members = gsuite_members : delete_members = gsuite_members - excel_members

  delete_members.each{|member|
    begin
      service.delete_member("#{group['email']}","#{member}")
      log.info("グループのメンバーを削除しました。#{group['name']}:#{member}")
    rescue => e
      log.fatal("グループのメンバー削除で異常が発生しました。#{group['name']}:#{member}")
      log.fatal("#{e}")
      mail.send("グループのメンバー削除で異常が発生しました。#{group['name']}:#{member}")
      next
    end
  }
}

