class Auth

  class << self

    #DirectoryServiceの認証
    def directory_auth
      service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = self.authorize
      service
    end

    #GroupsSettingsの認証
    def groups_settings_auth
      service = Google::Apis::GroupssettingsV1::GroupssettingsService.new()
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = self.authorize
      service
    end

    #認証
    def authorize
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

  end

end
