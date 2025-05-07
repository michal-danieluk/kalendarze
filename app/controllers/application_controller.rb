class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  
  # Helper method for rendering XLSX files
  def render_xlsx(filename = nil)
    filename ||= params[:action]
    filename += '.xlsx'

    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    render layout: false
  end
  
  protected
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Brak dostępu do panelu administratora.'
    end
  end
end
