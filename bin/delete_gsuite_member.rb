require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/constant.rb'
require './lib/excel_organization.rb'
require './lib/gsuite_group.rb'
require './lib/gsuite_user.rb'
require './lib/log.rb'

Log.instance
gsuite_group = Group.instance
gsuite_user = User.instance
excel = Organization.instance

gsuite_groups = gsuite_group.get_groups(head:"#{HEAD}")

gsuite_groups.each{|group|
  excel_members = Array.new

  gsuite_members = gsuite_group.get_members(group['address'])
  next if gsuite_members.empty?

  excel_members = excel.get_members(group['address'], group['name'])
  excel_members == nil ? delete_members = gsuite_members : delete_members = gsuite_members - excel_members

  delete_members.each{|delete_member|
    gsuite_group.delete_member(group['address'], delete_member)
  }
}
