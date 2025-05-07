class OrdersController < ApplicationController
  before_action :set_order, only: [:show]
  
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @order = Order.new
    @calendars = Calendar.all.order(:name)
  end

  def create
    @order = current_user.orders.build(order_params)
    @order.status = 'pending'
    
    if params[:order] && params[:order][:order_items_attributes]
      calendar_params = params[:order][:order_items_attributes]
      
      # Handle single item from show page
      if calendar_params.is_a?(Hash) && !calendar_params.key?('0')
        calendar_id = calendar_params[:"calendar_id"] || calendar_params["calendar_id"]
        quantity = calendar_params[:"quantity"] || calendar_params["quantity"]
        
        if calendar_id.present? && quantity.present? && quantity.to_i > 0
          @order.order_items.build(calendar_id: calendar_id, quantity: quantity)
        end
      else
        # Handle multiple items from new order form
        calendar_params.each do |_, item_params|
          if item_params[:calendar_id].present? && item_params[:quantity].present? && item_params[:quantity].to_i > 0
            @order.order_items.build(calendar_id: item_params[:calendar_id], quantity: item_params[:quantity])
          end
        end
      end
    end
    
    if @order.order_items.empty?
      @calendars = Calendar.all.order(:name)
      flash.now[:alert] = "Musisz wybrać co najmniej jeden kalendarz."
      render :new, status: :unprocessable_entity
    elsif @order.delivery_address.blank?
      @calendars = Calendar.all.order(:name)
      flash.now[:alert] = "Musisz podać adres dostawy."
      render :new, status: :unprocessable_entity
    elsif @order.save
      redirect_to @order, notice: 'Zamówienie zostało złożone i oczekuje na zatwierdzenie.'
    else
      @calendars = Calendar.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end
  
  private
  
  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: 'Nie znaleziono zamówienia.'
  end
  
  def order_params
    params.require(:order).permit(:delivery_address, :manager_email)
  end
end