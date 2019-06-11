require 'mail'

class SendMail

  include ::Mail

  def self.error(text)
    mail = Mail.new do
       from     'gsuite@dadway.com'
       to       's_urano@dadway.com'
       subject  "【GSuite】エラー通知"
       body     "#{text}"
    end

    mail.charset = 'utf-8'
   
    mail.delivery_method :smtp, { 
       address: 'dwml.dad-way.local',
       port: 25,
       domain: 'dadway.com'
    }
    mail.deliver!
  end

end

