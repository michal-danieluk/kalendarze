class Admin::CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_calendar, only: [:show, :edit, :update, :destroy]

  def index
    @calendars = Calendar.all.order(:name)
  end

  def show
  end

  def new
    @calendar = Calendar.new
  end

  def create
    @calendar = Calendar.new(calendar_params)

    if @calendar.save
      redirect_to admin_calendars_path, notice: 'Kalendarz został pomyślnie dodany.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @calendar.update(calendar_params)
      redirect_to admin_calendars_path, notice: 'Kalendarz został pomyślnie zaktualizowany.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @calendar.order_items.any?
      redirect_to admin_calendars_path, alert: 'Nie można usunąć kalendarza powiązanego z zamówieniami.'
    else
      @calendar.destroy
      redirect_to admin_calendars_path, notice: 'Kalendarz został pomyślnie usunięty.'
    end
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Brak dostępu.'
    end
  end

  def set_calendar
    @calendar = Calendar.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_calendars_path, alert: 'Nie znaleziono kalendarza.'
  end

  def calendar_params
    params.require(:calendar).permit(:name, :year, :calendar_type, :price, :description)
  end
end