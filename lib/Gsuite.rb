require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'singleton'
require './lib/Constant.rb'

class Gsuite

  include Singleton

  def directory_auth
    @directory_auth = Google::Apis::AdminDirectoryV1::DirectoryService.new()
    @directory_auth.client_options.application_name = APPLICATION_NAME
    @directory_auth.authorization = self.directory_authorize
  end

  def groups_settings_auth
    @groups_settings_auth = Google::Apis::GroupssettingsV1::GroupssettingsService.new
    @groups_settings_auth.client_options.application_name = APPLICATION_NAME
    @groups_settings_auth.authorization = self.groups_settings_authorize
  end

  #認証
  def directory_authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, ADMIN_SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end

  #認証
  def groups_settings_authorize
    FileUtils.mkdir_p(File.dirname(SETTING_CREDENTIALS_PATH))
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: SETTING_CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SETTING_SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
           "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end

  # GSuiteのユーザー取得処理はUser/Groupクラスの処理で使用するため、Gsuiteクラスに定義する。
  # user_checkメソッドも同様の理由によりGsuiteクラスに定義
  def get_users
      @gsuite_users = Array.new
      pagetoken = nil
      loop do
        begin
          list = @directory_auth.list_users(customer: 'my_customer', max_results: 500,  page_token: "#{pagetoken}")
          list.users.each{|user| 
            if user.phones.nil?
              @gsuite_users << { 'mail' => user.primary_email, 'family_name' => user.name.family_name, 'phone'=> ""}
            else
              user.phones.each{|phone| @gsuite_users << { 'mail' => user.primary_email, 'family_name' => user.name.family_name, 'phone'=> phone['value'] } }
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
      @gsuite_users
    end

    def user_check(user)
      mails = Array.new
      @gsuite_users.each{|gsuite_user| mails << gsuite_user['mail']}
      mails.include?(user)
    end

end
