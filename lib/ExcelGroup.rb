require './lib/Excel.rb'
require 'json'

class Organization < Excel

  def initialize
    @conferences = Hash.new
    File.open("./etc/organization.json") do |file|
      @conferences = JSON.load(file)
    end
    super(EMPLOYEE_FILE_NAME)
    groups = Array.new
    @data.each {|row|
#      next unless row['連絡先除外'].nil?
      next unless row['連絡先グループ除外'].nil?
      next if row['メールアドレス'].nil?
      groups << row
    }
    @data = groups
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

  def get_group_list
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
      @child_groups << { 'mail' => "#{row['グループ名(英名略称)'].downcase}#{DOMAIN}", 'name' =>  "#{row['グループ名(英名略称)']}",\
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
      @parent_groups << { 'mail' => "#{row['親組織'].downcase}#{DOMAIN}", 'name' =>  "#{row['親組織']}",\
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

  def get_members(group)
    if group['mail'] == @conferences['all']['mail']
      members = self.get_all
    elsif group['mail'] == @conferences['executive']['mail'] || group['mail'] == @conferences['mirai']['mail'] \
          || group['mail'] == @conferences['business_managers']['mail'] || group['mail'] == @conferences['contact']['mail']
      members = self.get_meeting_structure(group['header'])
    else 
      members = self.get_members_recurse(group['name'])
    end
    members
  end

    #def get_executive
  #  members = Array.new
  #  @data.each{|row|
  #    next if row['幹部会議メンバー'].nil?
  #    next unless row['兼務情報'].nil?
  #    members << row['メールアドレス']
  #  }
  #  members.sort
  #end

  #def get_determination
  #  members = Array.new
  #  @data.each{|row|
  #    next if row['決定報告会議メンバー'].nil?
  #    next unless row['兼務情報'].nil?
  #    members << row['メールアドレス']
  #  }
  #  members.sort
  #end
  
  #def get_meeting_header_name(group)
  #  group.sub!(/^DW_/, '')
  #  group.concat("メンバー")
  #end

end
