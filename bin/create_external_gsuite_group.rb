require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/gsuite_group.rb'
require './lib/log.rb'
require './lib/constant.rb'

# デバックするときはこちら↓
require './lib/excel_group.rb'
excel = ExcelGroup.new('external')

# rubyコマンドに引数渡して実行するときはこちら↓
# excel = nil
# ARGV.each{|arg|
#   require "./lib/Excel#{arg}.rb"
#   arg == "External" ? excel = External.instance : excel = Internal.instance
# }

Log.instance
gsuite_group = GsuiteGroup.instance

excel_groups = excel.get_groups

excel_groups.each{|group|
    next if gsuite_group.exist?(group['address'])
    gsuite_group.create_group(group, reference:'ANYONE_CAN_POST')
}