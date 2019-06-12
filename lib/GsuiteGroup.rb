require './lib/Gsuite.rb'
require './lib/GsuiteUser.rb'
require './lib/Constant.rb'
require './lib/Log.rb'
require './lib/Mail.rb'

class Group < Gsuite

  def initialize
    self.directory_auth
    self.groups_settings_auth
    self.get_users
  end

  # GSuite上に存在する全てのグループを取得したい場合と特定のグループを取得したい場合が存在する。
  # 引数を指定しない場合は、全てのグループを取得する。
  # 引数を指定する場合は、headとdescriptionを指定してグループ取得にフィルターをかけることが可能。
  def get_groups(**arg)
    @groups = Array.new
    pagetoken = ""
    loop do
      begin
        list = @directory_auth.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
        list.groups.each{|group| 
          @groups << {'mail' => group.email, 'name' => group.name, 'description' => group.description}
        }
        pagetoken = list.next_page_token
        break if pagetoken.nil?
      rescue => exception
        Log.error("GSuiteのグループ一覧取得でエラーが発生しました。")
        Log.error("#{exception}")
        SendMail.error("GSuiteのグループ一覧取得でエラーが発生しました。\n#{exception}")
        exit  
      end
    end
    # Hashに存在しないKeyを指定してnil?するとエラー（nil:NilClass (NoMethodError)）になる。
    # digメソッドを使うことで、Keyが存在しない場合はnilを返す。
    @groups.select!{|group| arg[:description] == group['description']} unless arg.dig(:description).nil?
    @groups.select!{|group| group['name'] =~ /^#{arg[:head]}/} unless arg.dig(:head).nil?
    @groups
  end

  def get_members(group)
    members = Array.new
    pagetoken = ""
    loop do
      begin
        list = @directory_auth.list_members("#{group}", page_token: "#{pagetoken}")
        list.members.each{|member| members << member.email} unless list.members.nil?
        pagetoken = list.next_page_token
        break if pagetoken.nil?
      rescue => exception
        Log.error("GSuiteのメンバー一覧取得でエラーが発生しました。")
        Log.error("#{exception}")
        SendMail.error("GSuiteのメンバー一覧取得でエラーが発生しました。\n#{exception}")
        exit
      end
    end
    members
  end

  # 組織（例:ICTG）の作成と社内/外部用の作成で若干挙動が異なる。
  # 社内/外部用を作成する場合は、第一引数にExcelで取得したグループ、第二引数にreferenceを指定すればOK
  # 組織を作成する場合は、第一引数にExcelで取得したグループ、第二第三引数にreferenceとheadを指定すればOK（第二第三引数は順不同）
  def create_groups(excel_groups, **arg)
    excel_groups.each{|excel_group| 
      # グループが既に存在している場合は、next
      next if group_check(excel_group['mail'])
      begin
        group = Google::Apis::AdminDirectoryV1::Group.new(
          email: "#{excel_group["mail"]}",
          name: "#{arg[:head]}#{excel_group["name"]}",
          description: "#{excel_group["description"]}"
        )
        #@directory_auth.insert_group(group)
      rescue => exception
        Log.error("グループの作成でエラーが発生しました。グループ名:#{excel_group['name']}/グループアドレス:#{excel_group['mail']}")
        Log.error("#{exception}")
        SendMail.error("グループの作成でエラーが発生しました。\nグループ名:#{excel_group['name']}\nグループアドレス:#{excel_group['mail']}\n#{exception}")
      else
        Log.info("グループを作成しました。#{excel_group['name']}:#{excel_group['mail']}")
      end
      begin
        group_setting = @groups_settings_auth.get_group("#{excel_group["mail"]}")
        next if  group_setting.who_can_post_message == "#{arg[:reference]}" && group_setting.show_in_group_directory == true

        setting = Google::Apis::GroupssettingsV1::Groups.new(
          who_can_post_message: "#{arg[:reference]}",
          show_in_group_directory: "#{SHOW_DIRECTORY}"
        )
        #@groups_settings_auth.patch_group("#{excel_group["mail"]}", setting)
      rescue => exception
        Log.error("グループの設定変更でエラーが発生しました。#{excel_group['name']}:#{excel_group['mail']}")
        Log.error("#{exception}")
        SendMail.error("グループの設定変更でエラーが発生しました。\nグループ設定を手動で行うかグループを削除してスクリプトを実行し直してください。\n#{excel_group['name']}:#{excel_group['mail']}\n#{exception}")
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
      next unless user_check(add_member) && group_check(excel_group['mail'])
      begin
        member = Google::Apis::AdminDirectoryV1::Member.new(
          email: "#{add_member}",
          role: "#{MEMBER_ROLE}"
        )
        #@directory_auth.insert_member(excel_group,member)
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

  def delete_members(gsuite_members, excel_members, gsuite_group)
    excel_members == nil ? delete_members = gsuite_members : delete_members = gsuite_members - excel_members
    delete_members.each{|delete_member|
      begin
        #@directory_auth.delete_member("#{gsuite_group['mail']}","#{delete_member}")
      rescue => exception
        Log.fatal("グループのメンバー削除でエラーが発生しました。グループ名:#{gsuite_group['name']}/削除対象メンバー:#{delete_member}")
        Log.fatal("#{exception}")
        SendMail.error("グループのメンバー削除で異常が発生しました。\nグループ名:#{gsuite_group['name']}\n削除対象メンバー:#{delete_member}\n#{exception}")
        next
      else
        Log.info("グループのメンバーを削除しました。グループ名：#{gsuite_group['name']}、削除対象メンバー:#{delete_member}")
        p "グループのメンバーを削除しました。グループ名：#{gsuite_group['name']}、削除対象メンバー:#{delete_member}"
      end
    }
  end

  def delete_groups(gsuite_group)
    begin
      #@directory_auth.delete_group("#{gsuite_group}")
    rescue => exception
      Log.error("グループの削除でエラーが発生しました。グループ名:#{gsuite_group}")
      Log.error("#{exception}")
      SendMail.error("グループの削除でエラーが発生しました。\nグループ名:#{gsuite_group}\n#{exception}")
    else
      Log.info("グループを削除しました。グループ名:#{gsuite_group}")
    end
  end

  private

    def group_check(group_mail)
      gsuite_groups = self.get_groups if @groups.nil?
      group_mail_list = Array.new
      gsuite_groups.each{|group| group_mail_list << group['mail']}
      group_mail_list.include?(group_mail)
    end

end
