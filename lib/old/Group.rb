require '/script/lib/Excel.rb'

class Group < Excel

  def initialize
    super
    groups = Array.new
    @data.each {|row|
#      next unless row['連絡先除外'].nil?
      next unless row['連絡先グループ除外'].nil?
      next if row['メールアドレス'].nil?
      groups << row
    }
    @data = groups
  end

  def get_executive
    members = Array.new
    @data.each{|row|
      next if row['幹部会議メンバー'].nil?
      next unless row['兼務情報'].nil?
      members << row['メールアドレス']
    }
    members.sort
  end

  def get_determination
    members = Array.new
    @data.each{|row|
      next if row['決定報告会議メンバー'].nil?
      next unless row['兼務情報'].nil?
      members << row['メールアドレス']
    }
    members.sort
  end
  
  def get_meeting_header_name(group)
    group.sub!(/^DW_/, '')
    group.concat("メンバー")
  end

  def get_meeting_structure(meeting_structure_name)
    members = Array.new
    @data.each{|row|
      next if row[meeting_structure_name].nil?
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
      @child_groups << row['グループ名(英名略称)'] unless row['グループ名(英名略称)'].nil?
    }
    @child_groups.uniq!
    @child_groups.compact!

    @child_groups

  end

  def get_parent_group_list

    @parent_groups = Array.new
    @data.each{|row|
      next if row['メールアドレス'].nil?
      @parent_groups << row['親組織'] unless row['親組織'].nil?
    }
    @parent_groups.uniq!
    @parent_groups.compact!

    @parent_groups

  end

  def get_members(group_name)
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

    return get_members(parent_group_name) if get_child_groups(parent_group_name) == nil

    members = Array.new
    members << get_members(parent_group_name)
    get_child_groups(parent_group_name).each {|child_group|
      members << get_members_recurse(child_group)
    }

    members.flatten!
    members.uniq!
    members.compact!
    members.sort

  end

end
