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

excel_users = excel.get_users

gsuite.update_users_name(excel_users)

gsuite.update_users_phone(excel_users)