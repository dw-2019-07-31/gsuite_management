require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
# require '/script/lib/constant.rb'
# require '/script/lib/gsuite_group.rb'
# require '/script/lib/gsuite_user.rb'
# require '/script/lib/log.rb'

# require '/script/lib/excel_organization.rb'
require_relative '../lib/constant.rb'
require_relative '../lib/gsuite_group.rb'
require_relative '../lib/gsuite_user.rb'
require_relative '../lib/log.rb'

require_relative '../lib/excel_organization.rb'
excel = Organization.new

Log.instance
gsuite_group = GsuiteGroup.instance
gsuite_user = User.instance

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
