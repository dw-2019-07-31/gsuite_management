require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/constant.rb'
require './lib/gsuite_group.rb'
require './lib/log.rb'

# デバックするときはこちら↓
require './lib/excel_group.rb'
excel = ExcelGroup.new('internal')

# rubyコマンドに引数渡して実行するときはこちら↓
# excel = nil
# ARGV.each{|arg|
#   require "./lib/excel_#{arg}.rb"
#   arg == "external" ? excel = External.instance : excel = Internal.instance
#   arg == "external" ? description = EXTERNAL_DESCRIPTION : description = INTERNAL_DESCRIPTION
# }

Log.instance
gsuite_group = GsuiteGroup.instance

gsuite_groups = gsuite_group.get_groups(description:"#{excel.description}")

gsuite_groups.each{|group|
  excel_members = Array.new

  gsuite_members = gsuite_group.get_members(group['address'])
  next if gsuite_members.empty?

  excel_members = excel.get_members(group['address'])

  excel_members == nil ? delete_members = gsuite_members : delete_members = gsuite_members - excel_members
  delete_members.each{|delete_member|
    gsuite_group.delete_member(group['address'], delete_member)
  }
}
