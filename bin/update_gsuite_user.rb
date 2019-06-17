require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require './lib/gsuite_user.rb'
require './lib/log.rb'
require './lib/excel_employee.rb'

log = Log.instance

excel = Employee.instance
gsuite = User.instance

excel_users = excel.get_users
gsuite_users = gsuite.get_users

excel_users.each{|excel_user|
    gsuite_users.each{|gsuite_user|
        next unless "#{gsuite_user['address']}" == "#{excel_user['メールアドレス']}"
        gsuite.update_user_phone(excel_user) unless "#{gsuite_user['phone']}" == "#{excel_user['会社貸与携帯番号']}"

        next if "#{excel_user['グループ名(英名略称)']}".empty?
        gsuite.update_user_name(excel_user) unless "#{gsuite_user['family_name']}" =~ /^#{excel_user['グループ名(英名略称)']}_/
    }
}
