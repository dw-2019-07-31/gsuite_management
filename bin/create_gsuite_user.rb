require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/ExcelEmployee.rb'
require './lib/GsuiteUser.rb'
require './lib/Log.rb'

Log.instance
gsuite = User.instance
excel = Employee.instance
p 'aaaaaaa'
excel_users = excel.get_users

gsuite.create_users(excel_users)