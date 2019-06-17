require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/excel_employee.rb'
require './lib/gsuite_user.rb'
require './lib/log.rb'

Log.instance
gsuite_user = User.instance
excel = Employee.instance

excel_users = excel.get_users

excel_users.each{|user|
    next if gsuite_user.exist?(user['メールアドレス'])
    gsuite_user.create_user(user)
}