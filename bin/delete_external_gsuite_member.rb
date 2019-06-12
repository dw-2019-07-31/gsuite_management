require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/Constant.rb'
require './lib/ExcelExternal.rb'
require './lib/GsuiteGroup.rb'
require './lib/Log.rb'

Log.instance
gsuite = Group.instance
excel = External.instance

gsuite_groups = gsuite.get_groups(description:"#{EXTERNAL_DESCRIPTION}")

gsuite_groups.each{|gsuite_group|
  excel_members = Array.new
  gsuite_members = gsuite.get_members(gsuite_group['mail'])
  next if gsuite_members.empty?
  excel_members = excel.get_members(gsuite_group['mail'])
  gsuite.delete_members(gsuite_members, excel_members, gsuite_group)
}
