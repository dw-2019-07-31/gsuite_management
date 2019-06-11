require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/ExcelExternal.rb'
require './lib/GsuiteGroup.rb'
require './lib/Log.rb'
require './lib/Constant.rb'

Log.instance
gsuite = Group.instance
excel = External.instance

excel_groups = excel.get_group_list

gsuite.create_groups(excel_groups, head:nil, reference:"#{EXTERNAL_REFERENSE}")