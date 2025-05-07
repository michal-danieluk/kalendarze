class Public::OrdersController < ApplicationController
  skip_before_action :authenticate_user!
  
  def new
    @order = Order.new
    @calendars = Calendar.all.order(:name)
  end

  def create
    @order = Order.new(order_params)
    @order.status = 'pending'
    
    if params[:order] && params[:order][:order_items_attributes]
      calendar_params = params[:order][:order_items_attributes]
      
      # Handle multiple items from order form
      calendar_params.each do |_, item_params|
        if item_params[:calendar_id].present? && item_params[:quantity].present? && item_params[:quantity].to_i > 0
          @order.order_items.build(calendar_id: item_params[:calendar_id], quantity: item_params[:quantity])
        end
      end
    end
    
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
      :delivery_address, 
      :customer_email, 
      :mpk_number, 
      :manager_email,
      order_items_attributes: [:calendar_id, :quantity]
    )
  end
end