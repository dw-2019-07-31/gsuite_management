require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/ExcelGroup.rb'
require './lib/GsuiteGroup.rb'
require './lib/Log.rb'

Log.instance
gsuite = Group.instance
excel = Organization.instance

excel_groups = excel.get_group_list

excel_groups.each{|excel_group|
  excel_members = Array.new
  excel_members = excel.get_members(excel_group)
  next if excel_members.nil?
  gsuite.add_members(excel_group, excel_members)
}

