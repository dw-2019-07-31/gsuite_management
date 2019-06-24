require 'roo'
require 'json'
require '/script/lib/constant.rb'
require '/script/lib/excel.rb'

class ExcelGroup < Excel
  attr_reader :description

  def initialize(division)
    group = read_json("/script/etc/group.json")
    file_name = group["#{division}"]['file']
    @description = group["#{division}"]['description']

    super(file_name)
    @data.each{|row| row['英語名称'] += "#{DOMAIN}" unless row['英語名称'] =~ /#{DOMAIN}$/ }
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

  def get_groups
    groups = Array.new
    @data.each{|row|
      check = nil
      groups.each{|group| (check = 1 ; break) if group['address'] == row['英語名称']}
      groups << {'address' => row['英語名称'], 'name' => row['連絡先グループ名'], 'description' => "#{@description}"} if check == nil
    }
    groups
  end

end