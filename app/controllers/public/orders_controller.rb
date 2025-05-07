class Public::OrdersController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_logged_in
  
  def redirect_if_logged_in
    if user_signed_in?
      redirect_to root_path, notice: 'Zalogowani użytkownicy nie mogą składać zamówień. Wyloguj się, aby złożyć zamówienie.'
    end
  end
  
  def new
    @order = Order.new
    # Nie tworzymy tutaj order_items, będą one tworzone w widoku
    @calendars = Calendar.all.order(:name)
  end

  def create
    @order = Order.new(order_params)
    @order.status = 'pending'
    
    # Usuwamy ręczne budowanie order_items, ponieważ są one już zawarte w order_params
    # dzięki accepts_nested_attributes_for :order_items w modelu Order
    
    if @order.order_items.empty?
      @calendars = Calendar.all.order(:name)
      flash.now[:alert] = "Musisz wybrać co najmniej jeden kalendarz."
      render :new, status: :unprocessable_entity
    elsif @order.save
      session[:order_id] = @order.id
      redirect_to public_order_path(@order), notice: 'Zamówienie zostało złożone i oczekuje na zatwierdzenie.'
    else
      @calendars = Calendar.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find_by(id: params[:id])
    
    unless @order && session[:order_id] == @order.id
      redirect_to root_path, alert: 'Nie masz dostępu do tego zamówienia.'
    end
  end
  
  private
  
  def order_params
    params.require(:order).permit(
      :customer_email, 
      :mpk_number, 
      :manager_email,
      :street,
      :house_number,
      :postal_code,
      :city,
      :phone_number,
      :delivery_notes,
      :delivery_address, # Keep for backward compatibility
      order_items_attributes: [:calendar_id, :quantity]
    )
  end
end