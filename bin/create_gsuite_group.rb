require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/ExcelGroup.rb'
require './lib/GsuiteGroup.rb'
require './lib/Log.rb'
require 'json'

Log.instance
gsuite = Ggroup.instance
excel = Egroup.instance

conferences = Hash.new

File.open("./etc/organization.json") do |file|
  conferences = JSON.load(file)
end

#会議体グループの作成
gsuite.create_groups(conferences)

excel_groups = excel.get_group_list

#組織グループの作成
gsuite.create_groups(excel_groups)