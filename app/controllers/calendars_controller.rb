class CalendarsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_calendar, only: [:show]
  
  def index
    @calendars = Calendar.all.order(:name)
  end

  def show
  end
  
  private
  
  def set_calendar
    @calendar = Calendar.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to calendars_path, alert: 'Nie znaleziono kalendarza.'
  end
end
