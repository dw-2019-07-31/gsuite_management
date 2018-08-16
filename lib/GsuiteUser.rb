require './lib/Gsuite.rb'
require './lib/Log.rb'
require './lib/Mail.rb'
require './lib/ExcelEmployee.rb'

class User < Gsuite
  
  def initialize
    self.directory_auth
  end

  def get_users
    
    users = Array.new
    pagetoken = ""

    loop do
      begin
        list = @directory_auth.list_users(customer: 'my_customer', max_results: 500,  page_token: "#{pagetoken}")
        list.users.each{|user| 
          if user.phones.nil?
            hash = { 'mail' => user.primary_email, 'family_name' => user.name.family_name, 'phone'=> ""}
          else
            user.phones.each{|phone|
              hash = { 'mail' => user.primary_email, 'family_name' => user.name.family_name, 'phone'=> phone['value']}
            }
          end
          users << hash
        }
        pagetoken = list.next_page_token
        break if pagetoken.nil?
      rescue => exception
        Log.error("Gsuiteのユーザー取得でエラーが発生しました。")
        SendMail.error("ユーザー作成でエラーが発生しました。\n#{exception}")
      end
    end

    users

  end

  def create_users(excel_users)

    gsuite_users = self.get_users

    excel_users.each{|excel_user|
      next unless gsuite_users.select{|user| user['mail'].include?("#{excel_user['メールアドレス']}")}.nil?

      orgunit = Employee.get_orgunits(excel_user)
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

    gsuite_users = self.get_users

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
          Log.error("ユーザー名の更新でエラーが発生しました。#{excel_user['メールアドレス']}:#{excel_user['姓']}#{excel_user['名']}")
          Log.error("#{exception}")
          SendMail.error("ユーザー名の更新でエラーが発生しました。#{excel_user['姓']}#{excel_user['名']}:#{excel_user['メールアドレス']}\n#{exception}")
          next
        else
          Log.info("ユーザー名を更新しました。#{excel_user['メールアドレス']}:#{excel_user['姓']}#{excel_user['名']}")
        end
      }
    }

  end

  def update_users_phone(excel_users)

    gsuite_users = self.get_users

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

  def check(employee)

    gsuite_user_email = Array.new
    @user_response.users.each{|user| gsuite_user_email << user.primary_email}
    gsuite_user_email.include?(employee)

  end

  #def get_orgunits
  #  users = Array.new
  #  keys = Array['メールアドレス','組織']
  #  user_response = @service.list_users(customer: 'my_customer', max_results: 500)
  #  user_response.users.each{|user|
  #    array = [keys, [user.primary_email, user.org_unit_path]].transpose
  #    hash = Hash[*array.flatten]
  #    users << hash
  #  }
  #  users
  #end

end
