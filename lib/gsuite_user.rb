require '/script/lib/gsuite.rb'
require '/script/lib/log.rb'
require '/script/lib/mail.rb'

class User < Gsuite
  
  def initialize
    self.get_directory_auth
  end

  def get_users
    @users = Array.new
    pagetoken = nil
    loop do
      begin
        list = @directory.list_users(customer: 'my_customer', max_results: 500,  page_token: "#{pagetoken}")
        list.users.each{|user| 
          if user.phones.nil?
            @users << { 'address' => user.primary_email, 'family_name' => user.name.family_name, 'phone'=> ""}
          else
            user.phones.each{|phone| @users << { 'address' => user.primary_email, 'family_name' => user.name.family_name, 'phone'=> phone['value'] } }
          end
        }
        pagetoken = list.next_page_token
        break if pagetoken.nil?
      rescue => exception
        Log.error("Gsuiteのユーザー取得でエラーが発生しました。")
        Log.error("#{exception}")
        SendMail.error("Gsuiteのユーザー取得でエラーが発生しました。\n#{exception}")
        exit
      end
    end
    @users
  end

  def exist?(target)
    user_address_list = Array.new
    @users == nil ? users = self.get_users : users = @users
    users.each{|user| user_address_list << user['address']}
    user_address_list.include?(target)
  end

  def create_user(user)
    user['グループ名(英名略称)'] == "#{MANAGEMENT_GROUP}" ? orgunit = "#{ORGUNIT_ICTG}" : orgunit = "#{ORGUNIT}"
    begin
      created_user = Google::Apis::AdminDirectoryV1::User.new(
          primary_email: "#{user['メールアドレス']}",
          name: {
            given_name: "#{user['名']}",
            family_name: "#{user['姓']}"
          },
          password: 'Dad880188',
          change_password_at_next_login: 'true',
          org_unit_path: "#{orgunit}",
          phones: [
            {
              value: "#{user['会社貸与携帯番号']}",
              type: 'work'
            }
          ]
      )
      @directory.insert_user(created_user)
    rescue => exception
      Log.error("ユーザー作成でエラーが発生しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}")
      Log.error("#{exception}")
      SendMail.error("ユーザー作成でエラーが発生しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}\n#{exception}")
      return
    else
      Log.info("ユーザーを作成しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}")
    end
  end

  def update_user_name(user)
    begin
      updated_user_name = Google::Apis::AdminDirectoryV1::User.new(
        name: {
          family_name: "#{user['グループ名(英名略称)']}_#{user['姓']}"
        }
      )
      @directory.update_user("#{user['メールアドレス']}",updated_user_name)
    rescue => exception
      Log.error("ユーザー名の更新でエラーが発生しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}")
      Log.error("#{exception}")
      SendMail.error("ユーザー名の更新でエラーが発生しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}\n#{exception}")
      return
    else
      Log.info("ユーザー名を更新しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}")
    end
  end

  def update_user_phone(user)
    begin
      updated_user_phone = Google::Apis::AdminDirectoryV1::User.new(
        phones: [{
          value: "#{user['会社貸与携帯番号']}",
          type: 'work'
        }]
      )
      @directory.update_user("#{user['メールアドレス']}", updated_user_phone)
    rescue => exception
      Log.error("ユーザーの電話番号更新でエラーが発生しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}")
      Log.error("#{exception}")
      SendMail.error("ユーザーの電話番号更新でエラーが発生しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}\n#{exception}")
      return
    else
      Log.info("ユーザーの電話番号を更新しました。#{user['姓']}#{user['名']}:#{user['メールアドレス']}")
    end
  end

end
