require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require '/script/lib/Constant.rb'
require '/script/lib/Auth.rb'

class Gsuite
  
  def initialize
    auth = Auth.new
    @service = Google::Apis::AdminDirectoryV1::DirectoryService.new()
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = auth.authorize
  end

end
