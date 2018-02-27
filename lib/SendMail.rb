require 'mail'

class ErrorMail
  include ::Mail

  def send(text)
    mail = Mail.new do
       from     'gsuite@dadway.com'
       to       'system_mgr@dadway.com'
       subject  "【GSuite】エラー通知"
       body     "#{text}"
    end
   
    mail.delivery_method :smtp, { 
       address: 'dwml.dad-way.local',
       port: 25,
       domain: 'dadway.com'
    }
    mail.deliver!
  end

end

