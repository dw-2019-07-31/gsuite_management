class Auth

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

   def setting_authorize
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


   def vault_authorize
     FileUtils.mkdir_p(File.dirname(SETTING_CREDENTIALS_PATH))

     client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
     token_store = Google::Auth::Stores::FileTokenStore.new(file: VAULT_CREDENTIALS_PATH)
     authorizer = Google::Auth::UserAuthorizer.new(
       client_id, VAULT_SCOPE, token_store)
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
