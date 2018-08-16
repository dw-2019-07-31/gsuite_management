require './lib/Gsuite.rb'
require './lib/Constant.rb'
require './lib/Log.rb'
require './lib/Mail.rb'

class Ggroup < Gsuite

  def initialize
    self.directory_auth
    self.groups_settings_auth
  end

  def get_groups

    groups = Array.new
    pagetoken = ""

    loop do
      begin
        list = @directory_auth.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
        list.groups.each{|group| 
          groups << {'mail' => group.email, 'name' => group.name, 'description' => group.description}
        }
        pagetoken = list.next_page_token
        break if pagetoken.nil?
      rescue => exception
        Log.error("Gsuiteのグループ一覧取得でエラーが発生しました。")
        Log.error("#{exception}")
        SendMail.error("Gsuiteのグループ一覧取得でエラーが発生しました。\n#{exception}")
        exit
      end
    end

    groups

  end

  def get_members(group)

    members = Array.new
    pagetoken = ""

    loop do
      begin
        list = @directory_auth.list_members("#{group['mail']}", page_token: "#{pagetoken}")
        list.members.each{|member| members << member.email} unless list.members.nil?
        pagetoken = list.next_page_token
        break if pagetoken.nil?
      rescue => exception
        Log.error("Gsuiteのメンバー一覧取得でエラーが発生しました。")
        Log.error("#{exception}")
        SendMail.error("Gsuiteのメンバー一覧取得でエラーが発生しました。\n#{exception}")
        exit
      end
    end

    members

  end

  def create_groups(excel_groups)

    gsuite_groups = self.get_groups

    excel_groups.each{|excel_group| 
      next unless gsuite_groups.select{|group| group['mail'] == excel_group['メールアドレス']}.nil?
      #next if gsuite_groups.include?("#{excel_group['mail']}")

      begin
        group = Google::Apis::AdminDirectoryV1::Group.new(
          email: "#{excel_group["mail"]}",
          name: "#{HEAD}#{excel_group["name"]}",
          description: "#{excel_group["description"]}"
        )
        #@directory_auth.insert_group(group)
      rescue => exception
        Log.error("グループの作成でエラーが発生しました。\nグループ名:#{excel_group['name']}/グループアドレス:#{excel_group['mail']}")
        Log.error("#{exception}")
        SendMail.error("グループの作成でエラーが発生しました。\nグループ名:#{excel_group['name']}\nグループアドレス:#{excel_group['mail']}\n#{exception}")
      else
        Log.info("グループを作成しました。#{excel_group['name']}:#{excel_group['mail']}")
      end

      begin
        group_setting = patch_service.get_group("#{excel_group["mail"]}")
        next if  group_setting.who_can_post_message == "#{GROUP_REFERENSE}" && group_setting.show_in_group_directory == true

        setting = Google::Apis::GroupssettingsV1::Groups.new(
          who_can_post_message: "#{GROUP_REFERENSE}",
          show_in_group_directory: "#{SHOW_DIRECTORY}"
        )
        #@groups_settings_auth.patch_group("#{excel_group["mail"]}", setting)
      rescue => exception
        Log.error("グループの設定変更でエラーが発生しました。#{excel_group['name']}:#{excel_group['mail']}")
        Log.error("#{exception}")
        SendMail.error("グループの設定変更でエラーが発生しました。#{excel_group['name']}:#{excel_group['mail']}\n#{exception}")
        next
      else
        Log.info("グループの設定変更をしました。#{excel_group['name']}:#{excel_group['mail']}")
      end
    }

  end

  def add_members(excel_group, excel_members)
        
    gsuite_members = self.get_members(excel_group)

    add_members = excel_members - gsuite_members
      
    add_members.each{|add_member|
      begin
        member = Google::Apis::AdminDirectoryV1::Member.new(
          email: "#{add_member}",
          role: "#{MEMBER_ROLE}"
        )
        #@directory_auth.insert_member("#{excel_group['email']}",member)
      rescue => exception
        Log.error("グループのメンバー追加でエラーが発生しました。グループ名:#{excel_group['name']}/追加メンバー:#{add_member}")
        Log.error("#{exception}")
        SendMail.error("グループのメンバー追加でエラーが発生しました。\nグループ名:#{excel_group['name']}\n追加メンバー:#{add_member}\n#{exception}")
        next
      else
        Log.info("グループにメンバーを追加しました。グループ名:#{excel_group['name']}/追加メンバー:#{add_member}")
      end
    }
    
  end

  def delete_members(excel_group, excel_members)

    gsuite_members = self.get_members(excel_group)

    excel_members == nil ? delete_members = gsuite_members : delete_members = gsuite_members - excel_members

    delete_members.each{|delete_member|
      begin
        #@directory_auth.delete_member("#{excel_group['mail']}","#{delete_member}")
      rescue => exception
        Log.fatal("グループのメンバー削除でエラーが発生しました。グループ名:#{excel_group['name']}、削除対象メンバー:#{delete_member}")
        Log.fatal("#{exception}")
        SendMail.error("グループのメンバー削除で異常が発生しました。\nグループ名:#{excel_group['name']}\n削除対象メンバー:#{delete_member}\n#{exception}")
        next
      else
        Log.info("グループのメンバーを削除しました。グループ名：#{excel_group['name']}、削除対象メンバー:#{delete_member}")
      end
    }

  end

  def delete_groups

    groups = self.get_groups

    groups.each{|group|

      members = Array.new
      members = self.get_members(group)
    
      next unless members.empty?
      begin
        #@directory_auth.delete_group("#{group}")
      rescue => exception
        Log.error("グループの削除でエラーが発生しました。グループ名:#{group}")
        Log.error("#{exception}")
        SendMail.error("グループの削除でエラーが発生しました。\nグループ名:#{group}\n#{exception}")
        next
      else
        Log.info("グループを削除しました。グループ名:#{group}")
      end
    }

  end

  def check(group)

    gsuite_group_email = Array.new
    @group_response.groups.each{|group| gsuite_group_email << group.email}
    gsuite_group_email.include?(group)

  end

end
