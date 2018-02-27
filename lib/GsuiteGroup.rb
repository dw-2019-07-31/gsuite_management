require '/script/lib/Gsuite.rb'
require '/script/lib/Auth.rb'

class GsuiteGroup < Gsuite

  def initialize
    super
    @group_response = @service.list_groups(customer: 'my_customer')
  end

  def check(group)

    gsuite_group_email = Array.new
    @group_response.groups.each{|group| gsuite_group_email << group.email}
    gsuite_group_email.include?(group)

  end

end
