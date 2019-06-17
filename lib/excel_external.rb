require 'roo'
require './lib/constant.rb'
require './lib/excel.rb'

class External < Excel

  def initialize
    super(EXTERNAL_FILE_NAME)
    @data.each{|row| row['英語名称'] += '@dadway.com' unless row['英語名称'] =~ /@dadway.com$/ }
    @data.each{|row| row.delete('管理者')}
  end

  def get
    @data
  end

  def get_members(address)
    members = Array.new
    @data.each{|row|
      next unless row['英語名称'] == address
      members << row['グループメンバー']
    }
    members
  end

  def get_groups
    groups = Array.new
    @data.each{|row|
      check = nil
      groups.each{|group| (check = 1 ; break) if group['address'] == row['英語名称']}
      groups << {'address' => row['英語名称'], 'name' => row['連絡先グループ名'], 'description' => "#{EXTERNAL_DESCRIPTION}"} if check == nil
    }
    groups
  end

end
