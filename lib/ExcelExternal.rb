require 'roo'
require './lib/Constant.rb'
require './lib/Excel.rb'

class External < Excel

  def initialize
    super(EXTERNAL_FILE_NAME)
    @data.each{|row| row['英語名称'] += '@dadway.com' unless row['英語名称'] =~ /@dadway.com$/ }
    @data.each{|row| row.delete('管理者')}
  end

  def get
    @data
  end

  def get_members(mail)
    members = Array.new
    @data.each{|row|
      next unless row['英語名称'] == mail
      members << row['グループメンバー']
    }
    members
  end

  def get_group_list
    groups = Array.new
    @data.each{|row|
      check = nil
      # groups.each{|group| (check = 1 ; break) if group['英語名称'] == row['英語名称']}
      groups.each{|group| (check = 1 ; break) if group['mail'] == row['英語名称']}
      groups << {'mail' => row['英語名称'], 'name' => row['連絡先グループ名'], 'description' => "#{EXTERNAL_DESCRIPTION}"} if check == nil
    }
    groups
  end

end
