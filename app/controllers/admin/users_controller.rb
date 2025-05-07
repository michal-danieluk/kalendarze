class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  def index
    @users = User.all.order(:role, :name)
    @supervisors = User.where(role: 'supervisor')
  end
  
  def show
  end
  
  def new
    @user = User.new
    @supervisors = User.where(role: 'supervisor')
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to admin_users_path, notice: "Użytkownik został pomyślnie utworzony."
    else
      @supervisors = User.where(role: 'supervisor')
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @supervisors = User.where(role: 'supervisor')
  end
  
  def update
    # Jeśli zmiana hasła nie jest wymagana, usuwamy puste hasło z parametrów
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Użytkownik został pomyślnie zaktualizowany."
    else
      @supervisors = User.where(role: 'supervisor')
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @user.destroy
      redirect_to admin_users_path, notice: "Użytkownik został pomyślnie usunięty."
    else
      redirect_to admin_users_path, alert: "Nie można usunąć użytkownika."
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :department, :supervisor_id)
  end
  
  def authorize_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień do tej sekcji."
    end
  end
end