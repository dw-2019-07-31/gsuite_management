require 'google/apis/admin_directory_v1'
require 'google/apis/groupssettings_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'singleton'
require './lib/constant.rb'

class Gsuite

  include Singleton

  def get_directory_auth
    @directory = Google::Apis::AdminDirectoryV1::DirectoryService.new()
    @directory.client_options.application_name = APPLICATION_NAME
    @directory.authorization = self.certify_directory
  end

  def get_groups_settings_auth
    @groups_settings = Google::Apis::GroupssettingsV1::GroupssettingsService.new
    @groups_settings.client_options.application_name = APPLICATION_NAME
    @groups_settings.authorization = self.certify_groups_settings
  end

  #認証
  def certify_directory
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
  def certify_groups_settings
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

  # # GSuite上に存在する全てのグループを取得したい場合と特定のグループを取得したい場合が存在する。
  # # 引数を指定しない場合は、全てのグループを取得する。
  # # 引数を指定する場合は、headとdescriptionを指定してグループ取得にフィルターをかけることが可能。
  # def get_groups(**arg)
  #   @groups = Array.new
  #   pagetoken = ""
  #   loop do
  #     begin
  #       list = @directory.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
  #       list.groups.each{|group| 
  #         @groups << {'address' => group.email, 'name' => group.name, 'description' => group.description}
  #       }
  #       pagetoken = list.next_page_token
  #       break if pagetoken.nil?
  #     rescue => exception
  #       Log.error("GSuiteのグループ一覧取得でエラーが発生しました。")
  #       Log.error("#{exception}")
  #       SendMail.error("GSuiteのグループ一覧取得でエラーが発生しました。\n#{exception}")
  #       exit  
  #     end
  #   end
  #   # Hashに存在しないKeyを指定してnil?するとエラー（nil:NilClass (NoMethodError)）になる。
  #   # digメソッドを使うことで、Keyが存在しない場合はnilを返す。
  #   @groups.select!{|group| arg[:description] == group['description']} unless arg.dig(:description).nil?
  #   @groups.select!{|group| group['name'] =~ /^#{arg[:head]}/} unless arg.dig(:head).nil?
  #   @groups
  # end

  # def get_members(group)
  #   @members = Array.new
  #   pagetoken = ""
  #   loop do
  #     begin
  #       list = @directory.list_members("#{group}", page_token: "#{pagetoken}")
  #       list.members.each{|member| @members << member.email} unless list.members.nil?
  #       pagetoken = list.next_page_token
  #       break if pagetoken.nil?
  #     rescue => exception
  #       Log.error("GSuiteのメンバー一覧取得でエラーが発生しました。")
  #       Log.error("#{exception}")
  #       SendMail.error("GSuiteのメンバー一覧取得でエラーが発生しました。\n#{exception}")
  #       exit
  #     end
  #   end
  #   @members
  # end

  # def exist_group?(target)
  #   group_address_list = Array.new
  #   groups = Array.new
  #   @groups == nil ? groups = self.get_groups : groups = @groups
  #   groups.each{|group| group_address_list << group['address']}
  #   group_address_list.include?(target)
  # end

end
