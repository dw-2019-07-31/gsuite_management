require './lib/Gsuite.rb'

class GsuiteEmployee < Gsuite
  
  def initialize
    super
  end

  def get_users
    users = Array.new
    user_response = @service.list_users(customer: 'my_customer', max_results: 500)
    user_response.users.each{|user| users << user.primary_email}
    users
  end

  def get_orgunits
    users = Array.new
    keys = Array['メールアドレス','組織']
    user_response = @service.list_users(customer: 'my_customer', max_results: 500)
    user_response.users.each{|user|
      array = [keys, [user.primary_email, user.org_unit_path]].transpose
      hash = Hash[*array.flatten]
      users << hash
    }
    users
  end

end
