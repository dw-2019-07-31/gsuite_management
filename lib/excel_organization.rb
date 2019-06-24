require '/script/lib/excel.rb'
require '/script/lib/constant.rb'
require 'json'

class Organization < Excel

  def initialize
    @conferences = read_json("/script/etc/conference.json")
    super(EMPLOYEE_FILE_NAME)
    groups = Array.new
    @data.each {|row|
      next unless row['連絡先グループ除外'].nil?
      next if row['メールアドレス'].nil?
      groups << row
    }
    @data = groups
  end

  def get_conferences
    conferences = Array.new
    @conferences.each_key{|key| conferences << @conferences["#{key}"]['address'] unless @conferences["#{key}"]['address'] == 'all@dadway.com'}
    conferences
  end

  def get_meeting_structure(header)
    members = Array.new
    @data.each{|row|
      next if row[header].nil?
      next unless row['兼務情報'].nil?
      members << row['メールアドレス']
    }
    members.sort
  end
  
  def get_all
    members = Array.new
    @data.each{|row|
      next unless row['兼務情報'].nil?
      members << row['メールアドレス']
    }
    members.sort
  end

  def get_groups
    groups = Array.new
    @conferences.each_key{|key| groups << @conferences["#{key}"]}
    get_child_group_list if @child_group.nil?
    get_parent_group_list if @parent_group.nil?
    groups << @child_groups
    groups << @parent_groups
    groups.flatten!
    groups.compact!
    groups.uniq
  end

  def get_child_group_list
    @child_groups = Array.new
    @data.each{|row|
      next if row['メールアドレス'].nil?
      #@child_groups << row['グループ名(英名略称)'] unless row['グループ名(英名略称)'].nil?
      @child_groups << { 'address' => "#{row['グループ名(英名略称)'].downcase}#{DOMAIN}", 'name' =>  "#{row['グループ名(英名略称)']}",\
                         'description' => "#{ORGANIZATION_DESCRIPTION}"} unless row['グループ名(英名略称)'].nil?
    }
    @child_groups.uniq!
    @child_groups.compact!
    @child_groups
  end

  def get_parent_group_list
    @parent_groups = Array.new
    @data.each{|row|
      next if row['メールアドレス'].nil?
      @parent_groups << { 'address' => "#{row['親組織'].downcase}#{DOMAIN}", 'name' =>  "#{row['親組織']}",\
                           'description' => "#{ORGANIZATION_DESCRIPTION}"} unless row['親組織'].nil?
    }
    @parent_groups.uniq!
    @parent_groups.compact!
    @parent_groups
  end

  def get_organization_members(group_name)
    members = Array.new
    @data.each{|row|
      next if row['メールアドレス'].nil?
      next if row['グループ名(英名略称)'].nil?
      members << row['メールアドレス'] if row['グループ名(英名略称)'] == group_name
    }
    return nil if members.count == 0
    members
  end

  def parse_hierarchy
    @hierarchy = Hash.new
    @data.each{|row|
      next if row['グループ名(英名略称)'].nil?
      next if row['親組織'].nil?
      if @hierarchy.key?(row['親組織'])
        if not @hierarchy[row['親組織']].include?(row['グループ名(英名略称)'])
          @hierarchy[row['親組織']] << row['グループ名(英名略称)']
        end
      else
        @hierarchy.store(row['親組織'], Array(row['グループ名(英名略称)']))
      end
    }
    return nil if @hierarchy.count == 0
    @hierarchy
  end

  def get_child_groups(parent_group_name)
    parse_hierarchy if @hierarchy.nil?
    @hierarchy[parent_group_name]
  end

  def get_members_recurse(parent_group_name)
    return get_organization_members(parent_group_name) if get_child_groups(parent_group_name) == nil
    members = Array.new
    members << get_organization_members(parent_group_name)
    get_child_groups(parent_group_name).each {|child_group|
      members << get_members_recurse(child_group)
    }
    members.flatten!
    members.uniq!
    members.compact!
    members.sort
  end

  def get_members(address, name=nil)
    if address == @conferences['all']['address']
      members = self.get_all
    elsif self.get_conferences().include?(address)
      members = self.get_meeting_structure(remove_DW(name).concat("メンバー"))
    else 
      members = self.get_members_recurse(remove_DW(name))
    end
    members
  end

  def remove_DW(group_name)
    group_name.sub!(/^DW_/, '') unless group_name !~ /^DW_/
    group_name
  end
  
end
