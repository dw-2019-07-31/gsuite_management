require './lib/Gsuite.rb'
require './lib/Log.rb'
require './lib/Mail.rb'
require './lib/ExcelEmployee.rb'

class User < Gsuite
  
  def initialize
    self.directory_auth
    self.get_users
  end

  def create_users(excel_users)
    orgunit = "#{ORGUNIT}"
    gsuite_users = @gsuite_users
    excel_users.each{|excel_user|
      next if user_check(excel_user['メールアドレス'])
      orgunit = "#{ORGUNIT_ICTG}" if excel_user['グループ名(英名略称)'] == "#{MANAGEMENT_GROUP}"
      begin
        user = Google::Apis::AdminDirectoryV1::User.new(
           primary_email: "#{excel_user['メールアドレス']}",
           name: {
              given_name: "#{excel_user['名']}",
              family_name: "#{excel_user['姓']}"
           },
           password: "#{PASSWORD}",
           change_password_at_next_login: 'true',
           org_unit_path: "#{orgunit}",
           phones: [
             {
               value: "#{excel_user['会社貸与携帯番号']}",
               type: 'work'
             }
           ]
        )
        #@directory_auth.insert_user(user)
      rescue => exception
        Log.error("ユーザー作成でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}")
        Log.error("#{exception}")
        SendMail.error("ユーザー作成でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}\n#{exception}")
        next
      else
        Log.info("ユーザーを作成しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}")
      end
    }
  end

  def update_users_name(excel_users)
    gsuite_users = @gsuite_users
    excel_users.each{|excel_user|
      gsuite_users.each{|gsuite_user|
        next unless "#{gsuite_user['mail']}" == "#{excel_user['メールアドレス']}"
        next if "#{excel_user['グループ名(英名略称)']}".empty?
        next if "#{gsuite_user['family_name']}" =~ /^#{excel_user['グループ名(英名略称)']}_/
        begin
          user = Google::Apis::AdminDirectoryV1::User.new(
            name: {
              family_name: "#{excel_user['グループ名(英名略称)']}_#{excel_user['姓']}"
            }
          )
          #@directory_auth.update_user("#{excel_user['メールアドレス']}",user)
        rescue => exception
          Log.error("ユーザー名の更新でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}:")
          Log.error("#{exception}")
          SendMail.error("ユーザー名の更新でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}\n#{exception}")
          next
        else
          Log.info("ユーザー名を更新しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}")
        end
      }
    }
  end

  def update_users_phone(excel_users)
    gsuite_users = @gsuite_users
    excel_users.each{|excel_user|
      gsuite_users.each{|gsuite_user|
        next unless "#{gsuite_user['mail']}" == "#{excel_user['メールアドレス']}"
        next if "#{gsuite_user['phone']}" == "#{excel_user['会社貸与携帯番号']}"
        begin
          user = Google::Apis::AdminDirectoryV1::User.new(
            phones: [{
             value: "#{excel_user['会社貸与携帯番号']}",
             type: 'work'
            }]
          )
          #@directory_auth.update_user("#{excel_user['メールアドレス']}", user)
        rescue => exception
          Log.error("ユーザーの電話番号更新でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}")
          Log.error("#{exception}")
          SendMail.error("ユーザーの電話番号更新でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}\n#{exception}")
          next
        else
          Log.info("ユーザーの電話番号を更新しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}")
        end
      }
    }
  end

end
