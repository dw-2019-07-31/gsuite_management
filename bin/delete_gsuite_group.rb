require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/GsuiteGroup.rb'
require './lib/Log.rb'

Log.instance
gsuite = Group.instance

gsuite_groups = gsuite.get_groups

# groupにメンバーがいなければ削除する。
gsuite_groups.each{|gsuite_group|
    members = Array.new
    members = gsuite.get_members(gsuite_group['mail'])
    next unless members.empty?
    gsuite.delete_groups(gsuite_group)
}