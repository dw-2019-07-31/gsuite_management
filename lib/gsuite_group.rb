# require '/script/lib/gsuite.rb'
# require '/script/lib/gsuite_user.rb'
# require '/script/lib/constant.rb'
# require '/script/lib/log.rb'
# require '/script/lib/mail.rb'

require_relative '../lib/gsuite.rb'
require_relative '../lib/gsuite_user.rb'
require_relative '../lib/constant.rb'
require_relative '../lib/log.rb'
require_relative '../lib/mail.rb'
class GsuiteGroup < Gsuite

  def initialize
    self.get_directory_auth
    self.get_groups_settings_auth
  end

  # GSuite上に存在する全てのグループを取得したい場合と特定のグループを取得したい場合が存在する。
  # 引数を指定しない場合は、全てのグループを取得する。
  # 引数を指定する場合は、headとdescriptionを指定することでグループ取得にフィルターをかけることができる。
  def get_groups(**arg)
    @groups = Array.new
    pagetoken = ""
    loop do
      begin
        list = @directory.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
        list.groups.each{|group| 
          @groups << {'address' => group.email, 'name' => group.name, 'description' => group.description}
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
        list = @directory.list_members("#{group}", page_token: "#{pagetoken}")
        list.members.each{|member| members << member.email.downcase} unless list.members.nil?
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

  def exist?(target)
    group_address_list = Array.new
    groups = Array.new
    @groups == nil ? groups = self.get_groups : groups = @groups
    groups.each{|group| group_address_list << group['address']}
    group_address_list.include?(target)
  end

  # 組織（例:ICTG）の作成と社内/外部用の作成で若干挙動が異なる。
  # 社内/外部用を作成する場合は、第一引数にグループ情報、第二引数にreferenceを指定すればOK
  # 組織を作成する場合は、第一引数にグループ情報、第二第三引数にreferenceとheadを指定すればOK（第二第三引数は順不同）
  def create_group(group, **arg)
    begin
      created_group = Google::Apis::AdminDirectoryV1::Group.new(
        email: "#{group['address']}",
        name: "#{arg[:head]}#{group['name']}",
        description: "#{group["description"]}"
      )
      @directory.insert_group(created_group)
    rescue => exception
      Log.error("グループの作成でエラーが発生しました。グループ名:#{arg[:head]}#{group['name']}/グループアドレス:#{group['address']}")
      Log.error("#{exception}")
      SendMail.error("グループの作成でエラーが発生しました。\nグループ名:#{arg[:head]}#{group['name']}\nグループアドレス:#{group['address']}\n#{exception}")
      return
    else
      Log.info("グループを作成しました。#{arg[:head]}#{group['name']}:#{group['address']}")
    end
    begin
      group_setting = @groups_settings.get_group("#{group['address']}")
      return if  group_setting.who_can_post_message == "#{arg[:reference]}" && group_setting.show_in_group_directory == true

      setting = Google::Apis::GroupssettingsV1::Groups.new(
        who_can_post_message: "#{arg[:reference]}",
        show_in_group_directory: 'true'
      )
      @groups_settings.patch_group("#{group["address"]}", setting)
    rescue => exception
      Log.error("グループの設定変更でエラーが発生しました。#{arg[:head]}#{group['name']}:#{group['address']}")
      Log.error("#{exception}")
      SendMail.error("グループの設定変更でエラーが発生しました。\nグループ設定を手動で行うかグループを削除してスクリプトを実行し直してください。\n#{arg[:head]}#{group['name']}:#{group['address']}\n#{exception}")
      return
    else
      Log.info("グループの設定変更をしました。#{arg[:head]}#{group['name']}:#{group['address']}")
    end
  end

  def add_member(group, member)
    begin
      added_member = Google::Apis::AdminDirectoryV1::Member.new(
        email: "#{member}",
        role: 'MEMBER'
      )
      @directory.insert_member(group,added_member)
    rescue => exception
      Log.error("グループのメンバー追加でエラーが発生しました。グループアドレス:#{group}/追加メンバー:#{member}")
      Log.error("#{exception}")
      SendMail.error("グループのメンバー追加でエラーが発生しました。\nグループアドレス:#{group}\n追加メンバー:#{member}\n#{exception}")
      return
    else
      Log.info("グループにメンバーを追加しました。グループアドレス:#{group}/追加メンバー:#{member}")
    end
  end

  def delete_member(group, member)
    begin
      @directory.delete_member("#{group}","#{member}")
    rescue => exception
      Log.fatal("グループのメンバー削除でエラーが発生しました。グループアドレス:#{group}/削除対象メンバー:#{member}")
      Log.fatal("#{exception}")
      SendMail.error("グループのメンバー削除で異常が発生しました。\nグループアドレス:#{group}\n削除対象メンバー:#{member}\n#{exception}")
      return
    else
      Log.info("グループのメンバーを削除しました。グループアドレス：#{group}、削除対象メンバー:#{member}")
    end
  end

  def delete_group(group)
    begin
      @directory.delete_group("#{group}")
    rescue => exception
      Log.error("グループの削除でエラーが発生しました。グループアドレス:#{group}")
      Log.error("#{exception}")
      SendMail.error("グループの削除でエラーが発生しました。\nグループアドレス:#{group}\n#{exception}")
      return
    else
      Log.info("グループを削除しました。グループアドレス:#{group}")
    end
  end

end
