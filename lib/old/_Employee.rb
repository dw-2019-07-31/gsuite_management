require '/script/lib/Excel.rb'
require '/script/lib/Constant.rb'

class Employee < Excel

  def initialize
    super
    @employees = Array.new
    @data.each{|row|
      next if row['メールアドレス'].nil?
      next unless row['兼務情報'].nil?
      row['メールアドレス'].gsub!(" ", "")
      (row['姓'] = row['名'] ; row['名'] = nil) if row['姓'].nil?
      row['名'] = 'メール' if row['名'].nil?
      @employees << row
    }
  end  

  def get
    @employees
  end

  def get_orgunit(employee)
    if employee['グループ名(英名略称)'] == "#{MANAGEMENT_GROUP}" || employee['親組織'] == "#{MANAGEMENT_GROUP}"
      orgunit  = '/ICTG'
    elsif employee['グループ名(英名略称)'] == "#{PUBLIC_RELATION_GROUP}" || employee['親組織'] == "#{PUBLIC_RELATION_GROUP}" ||\
          employee['グループ名(英名略称)'] == "#{WEB_GROUP}" || employee['親組織'] == "#{WEB_GROUP}"
      orgunit = '/広報、Web'
    else
      orgunit = '/Gmail、HOのみ'
    end 
    orgunit
  end

end
