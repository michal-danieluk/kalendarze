class OrderMailer < ApplicationMailer
  default from: 'system@kalendarze.pl'
  
  def summary_email(manager, orders, token)
    @manager = manager
    @orders = orders
    @token = token
    @url = bulk_approve_admin_orders_url(token: @token, manager_id: @manager.id)
    
    mail(to: @manager.email, subject: 'Zestawienie zamówień oczekujących na zatwierdzenie')
  end
  
  def email_summary_email(manager_email, orders, token)
    @manager_email = manager_email
    @orders = orders
    @token = token
    @url = bulk_approve_admin_orders_url(token: @token, manager_email: @manager_email)
    
    mail(to: @manager_email, subject: 'Zestawienie zamówień oczekujących na zatwierdzenie')
  end
end