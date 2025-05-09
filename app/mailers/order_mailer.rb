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

  def manager_approval_request(order)
    @order = order
    @token = generate_order_token(order)
    @approve_url = approve_order_url(token: @token, order_id: @order.id)
    @reject_url = reject_order_url(token: @token, order_id: @order.id)

    mail(
      to: @order.manager_email,
      subject: "Zatwierdzenie zamówienia ##{@order.id} od #{@order.customer_email}"
    )
  end

  def customer_order_confirmation(order)
    @order = order
    @order_url = public_order_url(@order)

    mail(
      to: @order.customer_email,
      subject: "Potwierdzenie złożenia zamówienia ##{@order.id}"
    )
  end

  private

  def generate_order_token(order)
    # Generate a secure token with expiration (24 hours)
    expiration = 24.hours.from_now.to_i
    data = { order_id: order.id, exp: expiration }

    # In production would use Rails.application.secret_key_base
    Base64.urlsafe_encode64(data.to_json)
  end

  def approve_order_url(token:, order_id:)
    admin_order_manager_approve_url(order_id, token: token)
  end

  def reject_order_url(token:, order_id:)
    admin_order_manager_reject_url(order_id, token: token)
  end
end