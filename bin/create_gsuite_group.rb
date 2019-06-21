require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/gsuite_group.rb'
require './lib/log.rb'
require './lib/constant.rb'

require './lib/excel_organization.rb'
excel = Organization.new

Log.instance
gsuite_group = GsuiteGroup.instance

excel_groups = excel.get_groups

excel_groups.each{|group|
    next if gsuite_group.exist?(group['address'])
    gsuite_group.create_group(group, reference:'ANYONE_CAN_POST', head:"#{HEAD}")
}