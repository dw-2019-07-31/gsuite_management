require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/GsuiteUser.rb'
require './lib/Log.rb'
require './lib/ExcelEmployee.rb'

log = Log.instance

excel = Employee.instance
gsuite = User.instance

gsuite_users_name = Array.new
gsuite_users_phone = Array.new

gsuite_users_name = gsuite.get_users_name
excel_users = excel.get_users

gsuite.update_user_name(excel_users, gsuite_users_name)

gsuite_users_phone = gsuite.get_users_phone

gsuite.update_user_phone(excel_users, gsuite_users_phone)