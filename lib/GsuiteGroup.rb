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

    gsuite_groups = Array.new
    pagetoken = ""

    loop do
      list = @directory_auth.list_groups(customer: 'my_customer', page_token: "#{pagetoken}")
      list.groups.each{|group| gsuite_groups << group.email}
      pagetoken = list.next_page_token
      break if pagetoken.nil?
    end

    gsuite_groups

  end

  def create_groups(excel_groups)

    gsuite_groups = self.get_groups

    excel_groups.each{|excel_group| 
      next if gsuite_groups.include?("#{excel_group['mail']}")

      begin
        group = Google::Apis::AdminDirectoryV1::Group.new(
          email: "#{excel_group["mail"]}",
          name: "#{excel_group["name"]}",
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
      else
        Log.info("グループの設定変更をしました。#{excel_group['name']}:#{excel_group['mail']}")
      end
    }

  end

  def check(group)

    gsuite_group_email = Array.new
    @group_response.groups.each{|group| gsuite_group_email << group.email}
    gsuite_group_email.include?(group)

  end

end
