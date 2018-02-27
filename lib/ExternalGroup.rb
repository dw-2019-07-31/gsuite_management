require '/script/lib/ExternalExcel.rb'

class ExternalGroup < ExternalExcel

  def initialize
    super
    @data.each{|row| 
      row['英語名称'] += '@dadway.com' unless row['英語名称'] =~ /@dadway.com$/
      }
    @data.each{|row| row.delete('管理者')}
  end

  def get
    @data
  end

  def get_members(english_name)
    members = Array.new
    @data.each{|row|
      next unless row['英語名称'] == english_name
      members << row['グループメンバー']
    }
    members
  end

  def get_group_list
    groups = Array.new
    @data.each{|row|
      check = nil
      groups.each{|group| (check = 1 ; break) if group['英語名称'] == row['英語名称']}
      groups << row if check == nil
    }
    groups
  end
end
