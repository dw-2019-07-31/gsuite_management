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

#ログの設定やら
log = Logger.new('/script/log/script.log')
log.progname = "add_member"

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

#list = service.list_groups(customer: 'my_customer')
#list.groups.each{|group| groups << {'email' => group.email, 'name' => group.name} if group.name =~ /^DW_/}

pagetoken = ""
loop do
  list = service.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
  list.groups.each{|group| groups << {'email' => group.email, 'name' => group.name} if group.name =~ /^DW_/}
  pagetoken = list.next_page_token
  break if pagetoken.nil?
end

groups.each{|group|
  excel_members = Array.new
  gsuite_members = Array.new

  if group['email'] == "#{ALL}"
    excel_members = excel.get_all
  elsif conference.include?("#{group['email']}") == true
    meeting_structure_name = excel.get_meeting_header_name("#{group['name']}")
    excel_members = excel.get_meeting_structure("#{meeting_structure_name}")
  else 
    excel_members = excel.get_members_recurse("#{group['email'].sub(/@dadway.com/, "").upcase}")
  end

  next if excel_members.nil?

  pagetoken = ""
  loop do
    list = service.list_members("#{group['email']}", page_token: "#{pagetoken}")
    list.members.each{|member| gsuite_members << member.email} unless list.members.nil?
    pagetoken = list.next_page_token
    break if pagetoken.nil?
  end

  add_members = excel_members - gsuite_members
  
  add_members.each{|member|
    begin
      add_member = Google::Apis::AdminDirectoryV1::Member.new(
        email: "#{member}",
        role: "#{MEMBER_ROLE}"
      )
      service.insert_member("#{group['email']}",add_member)
      log.info("グループにメンバーを追加しました。#{group['name']}:#{member}")
    rescue => e
      log.fatal("グループのメンバー追加で異常が発生しました。#{group['name']}:#{member}")
      log.fatal("#{e}")
      mail.send("グループのメンバー追加で異常が発生しました。#{group['name']}:#{member}")
      next
    end
  }
}

