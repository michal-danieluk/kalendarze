require 'mailgun-ruby'

class MailgunDeliveryMethod
  attr_accessor :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    mg_client = Mailgun::Client.new(settings[:api_key])
    mg_domain = settings[:domain]

    mb_obj = Mailgun::MessageBuilder.new
    mb_obj.from(mail.from.first)
    mail.to.each { |recipient| mb_obj.add_recipient(:to, recipient) }
    mail.cc.each { |cc| mb_obj.add_recipient(:cc, cc) } if mail.cc
    mail.bcc.each { |bcc| mb_obj.add_recipient(:bcc, bcc) } if mail.bcc
    mb_obj.subject(mail.subject)

    # Handle multipart emails
    if mail.multipart?
      if mail.html_part
        mb_obj.body_html(mail.html_part.body.to_s)
      end
      if mail.text_part
        mb_obj.body_text(mail.text_part.body.to_s)
      end
    else
      if mail.content_type&.include?('text/html')
        mb_obj.body_html(mail.body.to_s)
      else
        mb_obj.body_text(mail.body.to_s)
      end
    end

    # Handle attachments
    if mail.attachments.any?
      mail.attachments.each do |attachment|
        mb_obj.add_attachment(
          StringIO.new(attachment.body.to_s),
          attachment.filename,
          attachment.content_type
        )
      end
    end

    # Send the message
    mg_client.send_message(mg_domain, mb_obj)
  end
end

# Register the delivery method after the class is defined
ActionMailer::Base.add_delivery_method :mailgun, MailgunDeliveryMethod