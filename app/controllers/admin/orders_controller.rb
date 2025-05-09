class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_or_supervisor
  before_action :set_order, only: [:show, :confirm, :reject, :edit_manager, :update_manager]
  
  def index
    # Base query depends on user role
    base_orders = if current_user.admin?
      Order.all.includes(:confirmed_by)
    else
      # For supervisors, include only anonymous orders with their email as manager_email
      Order.where(manager_email: current_user.email)
           .includes(:confirmed_by)
    end
    
    # Filter by status if provided
    @status = params[:status]
    filtered_orders = @status.present? ? base_orders.where(status: @status) : base_orders
    
    # Filter by MPK if provided
    @mpk_filter = params[:mpk]
    filtered_orders = filtered_orders.where(mpk_number: @mpk_filter) if @mpk_filter.present?
    
    # Filter by manager email if provided
    @manager_filter = params[:manager]
    filtered_orders = filtered_orders.where(manager_email: @manager_filter) if @manager_filter.present?
    
    # Apply sorting
    @sort_by = params[:sort_by] || 'created_at'
    @sort_direction = params[:sort_direction] || 'desc'
    
    # Validate sort_by to prevent SQL injection
    allowed_sort_fields = ['id', 'created_at', 'status', 'customer_email', 'mpk_number', 'manager_email']
    @sort_by = 'created_at' unless allowed_sort_fields.include?(@sort_by)
    
    # Validate sort_direction
    @sort_direction = 'desc' unless ['asc', 'desc'].include?(@sort_direction)
    
    # Apply ordering
    @orders = filtered_orders.order(@sort_by => @sort_direction)
    
    # Prepare collections for tabs
    @pending_orders = base_orders.pending
    @sent_for_approval_orders = base_orders.sent_for_approval
    @confirmed_orders = base_orders.confirmed
    @rejected_orders = base_orders.rejected
    
    # Set active tab based on status parameter
    @active_tab = @status || 'pending'
    
    # Get unique MPK values and manager emails for filters
    @mpk_values = Order.distinct.pluck(:mpk_number).compact.sort
    @manager_emails = Order.distinct.pluck(:manager_email).compact.sort
  end

  def show
  end

  def confirm
    previous_status = @order.status
    
    if @order.confirm(current_user)
      if request.referer&.include?('admin/orders/') && !request.referer&.include?('?')
        # If coming from order details page, stay there
        redirect_to admin_order_path(@order), notice: 'Zamówienie zostało zatwierdzone.'
      else
        # Otherwise, redirect to the appropriate tab based on where we came from
        redirect_to admin_orders_path(status: 'confirmed'), notice: 'Zamówienie zostało zatwierdzone.'
      end
    else
      redirect_to admin_order_path(@order), alert: 'Nie udało się zatwierdzić zamówienia.'
    end
  end

  def reject
    previous_status = @order.status
    
    if @order.reject(current_user)
      if request.referer&.include?('admin/orders/') && !request.referer&.include?('?')
        # If coming from order details page, stay there
        redirect_to admin_order_path(@order), notice: 'Zamówienie zostało odrzucone.'
      else
        # Otherwise, redirect to the appropriate tab
        redirect_to admin_orders_path(status: 'rejected'), notice: 'Zamówienie zostało odrzucone.'
      end
    else
      redirect_to admin_order_path(@order), alert: 'Nie udało się odrzucić zamówienia.'
    end
  end
  
  def edit_manager
    # Only allow admins to edit manager information
    unless current_user.admin?
      redirect_to admin_order_path(@order), alert: 'Nie masz uprawnień do edycji danych managera.'
      return
    end
  end
  
  def update_manager
    # Only allow admins to update manager information
    unless current_user.admin?
      redirect_to admin_order_path(@order), alert: 'Nie masz uprawnień do edycji danych managera.'
      return
    end
    
    if @order.update(manager_params)
      redirect_to admin_order_path(@order), notice: 'Dane managera zostały zaktualizowane.'
    else
      render :edit_manager, status: :unprocessable_entity
    end
  end

  def export
    @status = params[:status]
    @orders = if @status.present?
      Order.where(status: @status).includes(:confirmed_by, order_items: :calendar)
    else
      Order.all.includes(:confirmed_by, order_items: :calendar)
    end
    
    respond_to do |format|
      format.html
      format.xlsx do
        status_text = case @status
                     when "pending" then "oczekujace"
                     when "confirmed" then "zatwierdzone"
                     when "rejected" then "odrzucone"
                     else "wszystkie"
                     end
        
        filename = "zamowienia_#{status_text}_#{Time.current.strftime('%Y%m%d_%H%M%S')}"
        response.headers['Content-Disposition'] = "attachment; filename=#{filename}.xlsx"
      end
    end
  end
  
  def send_summary
    # Znajdź wszystkich managerów
    @managers = User.where(role: 'supervisor')
    
    if params[:manager_id].present? && params[:confirm].blank?
      # Jeśli wybrano managera, ale jeszcze nie potwierdzono
      @manager = User.find(params[:manager_id])
      
      # Znajdź oczekujące zamówienia dla tego managera (teraz tylko po emailu)
      @pending_orders = Order.where(status: 'pending', manager_email: @manager.email)
                          .includes(order_items: :calendar)
      
      if @pending_orders.any?
        # Pokaż podgląd przed wysłaniem
        render :preview_summary
      else
        # Jeśli nie ma żadnych oczekujących zamówień
        redirect_to admin_orders_path, alert: "Brak oczekujących zamówień dla managera #{@manager.name}."
      end
    elsif params[:manager_id].present? && params[:confirm].present?
      # Jeśli potwierdzono wysyłkę
      manager = User.find(params[:manager_id])
      send_summary_to_manager(manager)
      redirect_to admin_orders_path, notice: "Zestawienie zamówień zostało wysłane do #{manager.name}."
    else
      # Przygotuj formularz do wyboru managera
      render :select_manager
    end
  end
  
  def send_summary_by_email
    if request.post?
      if params[:manager_email].present? && params[:confirm].present?
        # If confirmed sending via POST
        manager_email = params[:manager_email]
        send_summary_by_email_to_manager(manager_email)
        redirect_to admin_orders_path, notice: "Zestawienie zamówień zostało wysłane na adres #{manager_email}."
      elsif params[:manager_email].present?
        # Show preview before sending (POST with email parameter but without confirm)
        @manager_email = params[:manager_email]
        
        # Find all pending orders for this manager email
        @pending_orders = Order.where(status: 'pending', manager_email: @manager_email)
                          .includes(order_items: :calendar)
        
        # Always render the preview page, even if there are no orders
        # The view will handle the empty state appropriately
        render :preview_by_email
      else
        redirect_to send_summary_by_email_admin_orders_path, alert: "Musisz podać adres email managera."
      end
    else
      # Initial GET request - prepare the manager selection page
      
      # Get all pending orders
      pending_orders = Order.where(status: 'pending')
      
      # Group pending orders by manager email and count them
      manager_counts = pending_orders.group(:manager_email).count
      
      # Create a collection of pending managers with their order counts and name info
      @pending_managers = manager_counts.map do |email, count|
        next if email.blank?
        
        # Find the first order with this manager email to get name data
        order = pending_orders.find_by(manager_email: email)
        {
          email: email,
          name: order&.manager_name,
          count: count
        }
      end.compact.sort_by { |m| [-m[:count], m[:email]] } # Sort by count (desc) then email (asc)
      
      render :select_manager_by_email
    end
  end
  
  def bulk_approve
    token = params[:token]
    manager_id = params[:manager_id]
    manager_email = params[:manager_email]
    
    if manager_id.present?
      # Weryfikacja tokenu dla użytkownika-managera
      manager = User.find_by(id: manager_id)
      
      if manager && valid_token?(token, manager)
        # Znajdź wszystkie oczekujące anonimowe zamówienia dla tego managera po emailu
        pending_orders = Order.where(status: 'pending', manager_email: manager.email)
        
        # Zatwierdź wszystkie zamówienia
        if pending_orders.any?
          pending_orders.each do |order|
            order.confirm(manager)
          end
          
          # Przekieruj na stronę potwierdzenia
          redirect_to admin_orders_path(status: 'confirmed'), notice: "Zatwierdzono #{pending_orders.count} zamówień."
        else
          redirect_to admin_orders_path, alert: "Brak oczekujących zamówień do zatwierdzenia."
        end
      else
        redirect_to root_path, alert: "Nieprawidłowy token lub link wygasł."
      end
    elsif manager_email.present?
      # Weryfikacja tokenu dla adresu email managera
      if valid_email_token?(token, manager_email)
        # Znajdź wszystkie oczekujące zamówienia dla tego adresu email managera
        # Zarówno dla anonimowych jak i zamówień zalogowanych użytkowników
        pending_orders = Order.where(status: 'pending', manager_email: manager_email)
        
        # Znajdź istniejącego użytkownika o podanym adresie email lub utwórz tymczasowego do potwierdzenia
        confirming_user = User.find_by(email: manager_email)
        
        # Jeśli nie ma takiego użytkownika, użyj administratora systemu
        confirming_user ||= User.find_by(role: 'admin')
        
        # Zatwierdź wszystkie zamówienia
        if pending_orders.any? && confirming_user
          pending_orders.each do |order|
            order.confirm(confirming_user)
          end
          
          # Przekieruj na stronę potwierdzenia
          redirect_to admin_orders_path(status: 'confirmed'), notice: "Zatwierdzono #{pending_orders.count} zamówień."
        else
          redirect_to admin_orders_path, alert: "Brak oczekujących zamówień do zatwierdzenia lub brak uprawnionego użytkownika."
        end
      else
        redirect_to root_path, alert: "Nieprawidłowy token lub link wygasł."
      end
    else
      redirect_to root_path, alert: "Brak parametrów do zatwierdzenia zamówień."
    end
  end
  
  private
  
  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_orders_path, alert: 'Nie znaleziono zamówienia.'
  end
  
  def authorize_admin_or_supervisor
    unless current_user.admin? || current_user.supervisor?
      redirect_to root_path, alert: 'Nie masz uprawnień do tej sekcji.'
    end
  end
  
  def manager_params
    params.require(:order).permit(:manager_first_name, :manager_last_name)
  end
  
  def send_summary_to_manager(manager)
    # Znajdź oczekujące zamówienia dla tego managera (po adresie email)
    pending_orders = Order.where(status: 'pending', manager_email: manager.email)
                        .includes(order_items: :calendar)
    
    if pending_orders.any?
      # Wygeneruj token bezpieczeństwa
      token = generate_token(manager)
      
      # Wyślij maila z zestawieniem
      OrderMailer.summary_email(manager, pending_orders, token).deliver_now
      
      # Zmień status zamówień na "wysłane do akceptacji"
      pending_orders.each do |order|
        order.mark_as_sent_for_approval
      end
    end
  end
  
  def send_summary_by_email_to_manager(manager_email)
    # Znajdź wszystkie oczekujące zamówienia dla tego adresu email managera
    # Zarówno dla zamówień anonimowych jak i zamówień zalogowanych użytkowników
    pending_orders = Order.where(status: 'pending', manager_email: manager_email)
                        .includes(order_items: :calendar)
    
    if pending_orders.any?
      # Wygeneruj token bezpieczeństwa dla adresu email
      token = generate_email_token(manager_email)
      
      # Wyślij maila z zestawieniem
      OrderMailer.email_summary_email(manager_email, pending_orders, token).deliver_now
      
      # Zmień status zamówień na "wysłane do akceptacji"
      pending_orders.each do |order|
        order.mark_as_sent_for_approval
      end
    end
  end
  
  def generate_token(manager)
    # Generowanie tokenu z czasem ważności (24 godziny)
    expiration = 24.hours.from_now.to_i
    data = { manager_id: manager.id, exp: expiration }
    
    # Bardzo uproszczona implementacja - w produkcji powinna używać Rails.application.secret_key_base
    Base64.urlsafe_encode64(data.to_json)
  end
  
  def generate_email_token(manager_email)
    # Generowanie tokenu z czasem ważności (24 godziny)
    expiration = 24.hours.from_now.to_i
    data = { manager_email: manager_email, exp: expiration }
    
    # Bardzo uproszczona implementacja - w produkcji powinna używać Rails.application.secret_key_base
    Base64.urlsafe_encode64(data.to_json)
  end
  
  def valid_token?(token, manager)
    begin
      # Dekodowanie tokenu
      data = JSON.parse(Base64.urlsafe_decode64(token))
      
      # Sprawdzenie czy token należy do właściwego managera i czy nie wygasł
      data["manager_id"] == manager.id && 
      data["exp"] > Time.now.to_i
    rescue
      false
    end
  end
  
  def valid_email_token?(token, manager_email)
    begin
      # Dekodowanie tokenu
      data = JSON.parse(Base64.urlsafe_decode64(token))

      # Sprawdzenie czy token należy do właściwego adresu email managera i czy nie wygasł
      data["manager_email"] == manager_email &&
      data["exp"] > Time.now.to_i
    rescue
      false
    end
  end

  def valid_order_token?(token, order_id)
    begin
      # Decode the token
      data = JSON.parse(Base64.urlsafe_decode64(token))

      # Check if token belongs to the correct order and hasn't expired
      data["order_id"] == order_id.to_i &&
      data["exp"] > Time.now.to_i
    rescue
      false
    end
  end

  def manager_approve
    process_manager_action(:confirm)
  end

  def manager_reject
    process_manager_action(:reject)
  end

  private

  def process_manager_action(action)
    token = params[:token]
    order_id = params[:id]

    @order = Order.find_by(id: order_id)

    if @order && valid_order_token?(token, @order.id)
      # Find manager user or create a temporary confirmation user
      confirming_user = User.find_by(email: @order.manager_email)
      confirming_user ||= User.find_by(role: 'admin') # Fallback to admin

      if action == :confirm
        if @order.confirm(confirming_user)
          @status = 'confirmed'
          render 'manager_response', layout: false
        else
          redirect_to root_path, alert: "Nie udało się zatwierdzić zamówienia."
        end
      elsif action == :reject
        if @order.reject(confirming_user)
          @status = 'rejected'
          render 'manager_response', layout: false
        else
          redirect_to root_path, alert: "Nie udało się odrzucić zamówienia."
        end
      end
    else
      redirect_to root_path, alert: "Nieprawidłowy token lub link wygasł."
    end
  end
end