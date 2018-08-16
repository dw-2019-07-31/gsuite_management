require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/GsuiteGroup.rb'
require './lib/Log.rb'

Log.instance
gsuite = Ggroup.instance

gsuite.delete_groups