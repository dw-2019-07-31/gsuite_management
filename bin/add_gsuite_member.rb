require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require '/script/lib/gsuite_group.rb'
require '/script/lib/gsuite_user.rb'
require '/script/lib/log.rb'

require '/script/lib/excel_organization.rb'
excel = Organization.new

Log.instance
gsuite_group = GsuiteGroup.instance
gsuite_user = User.instance

excel_groups = excel.get_groups

excel_groups.each{|group|
  excel_members = Array.new
  gsuite_members = Array.new

  next unless gsuite_group.exist?(group['address'])

  excel_members = excel.get_members(group['address'], group['name'])
  next if excel_members.empty?

  gsuite_members = gsuite_group.get_members(group['address'])
  add_members = excel_members - gsuite_members
  add_members.each{|add_member|
    next unless gsuite_user.exist?(add_member)
    gsuite_group.add_member(group['address'], add_member)
  }
}

