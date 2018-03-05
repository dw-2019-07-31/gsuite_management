require '/script/lib/Gsuite.rb'
require '/script/lib/Auth.rb'

class User < Gsuite

  def initialize
    super
    @user_response = @service.list_users(customer: 'my_customer', max_results: 500)

  end

  def check(employee)

    gsuite_user_email = Array.new
    @user_response.users.each{|user| gsuite_user_email << user.primary_email}
    gsuite_user_email.include?(employee)

  end

end
