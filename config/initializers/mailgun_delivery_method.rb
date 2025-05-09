require 'mailgun-ruby'

class MailgunDeliveryMethod
  attr_accessor :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    # Log settings at time of delivery
    Rails.logger.info "=== MAILGUN DELIVERY DEBUG ==="
    Rails.logger.info "API Key: #{settings[:api_key].to_s.gsub(/.(?=.{4})/, '*')}" # Mask most of the API key
    Rails.logger.info "Domain: #{settings[:domain]}"

    begin
      mg_client = Mailgun::Client.new(settings[:api_key])
      mg_domain = settings[:domain]

      mb_obj = Mailgun::MessageBuilder.new
      mb_obj.from(mail.from.first)
      Rails.logger.info "From: #{mail.from.first}"

      mail.to.each { |recipient|
        mb_obj.add_recipient(:to, recipient)
        Rails.logger.info "To: #{recipient}"
      }
      mail.cc.each { |cc| mb_obj.add_recipient(:cc, cc) } if mail.cc
      mail.bcc.each { |bcc| mb_obj.add_recipient(:bcc, bcc) } if mail.bcc

      mb_obj.subject(mail.subject)
      Rails.logger.info "Subject: #{mail.subject}"

      # Handle multipart emails
      if mail.multipart?
        Rails.logger.info "Email is multipart"
        if mail.html_part
          mb_obj.body_html(mail.html_part.body.to_s)
          Rails.logger.info "HTML part included"
        end
        if mail.text_part
          mb_obj.body_text(mail.text_part.body.to_s)
          Rails.logger.info "Text part included"
        end
      else
        Rails.logger.info "Email is not multipart"
        if mail.content_type&.include?('text/html')
          mb_obj.body_html(mail.body.to_s)
          Rails.logger.info "Content is HTML"
        else
          mb_obj.body_text(mail.body.to_s)
          Rails.logger.info "Content is plain text"
        end
      end

      # Handle attachments
      if mail.attachments.any?
        Rails.logger.info "Attachments: #{mail.attachments.length}"
        mail.attachments.each do |attachment|
          mb_obj.add_attachment(
            StringIO.new(attachment.body.to_s),
            attachment.filename,
            attachment.content_type
          )
          Rails.logger.info "Attachment: #{attachment.filename} (#{attachment.content_type})"
        end
      end

      # Send the message
      Rails.logger.info "Attempting to send message via Mailgun..."
      result = mg_client.send_message(mg_domain, mb_obj)
      Rails.logger.info "Mailgun API response: #{result.to_h}"

      return result
    rescue => e
      Rails.logger.error "Mailgun delivery error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    ensure
      Rails.logger.info "=== END MAILGUN DELIVERY DEBUG ==="
    end
  end
end

# Register the delivery method after the class is defined
ActionMailer::Base.add_delivery_method :mailgun, MailgunDeliveryMethod