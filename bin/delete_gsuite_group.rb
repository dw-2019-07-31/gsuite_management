require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require '/script/lib/gsuite_group.rb'
require '/script/lib/log.rb'

Log.instance
gsuite_group = GsuiteGroup.instance

gsuite_groups = gsuite_group.get_groups

# groupにメンバーがいなければ削除する。
gsuite_groups.each{|group|
  members = Array.new
  
  members = gsuite_group.get_members(group['address'])
  next unless members.empty?
  gsuite_group.delete_groups(group['address'])
}