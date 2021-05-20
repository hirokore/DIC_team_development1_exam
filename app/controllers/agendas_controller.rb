class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end

  #AgendasControllerのdestroyアクションを追加し、そこに機能追加する
  def destroy
    if @agenda.user == current_user || @agenda.team.owner == current_user
      @agenda.destroy
      redirect_to dashboard_path, notice: "削除完了"
      users = User.where(id: Assign.where(team_id: @agenda.team_id).pluck(:user_id))
      users.each do |user|
        AssignMailer.assign_mail(user.email).deliver
      end
    else
      redirect_to dashboard_path, notice: "どうやら権限がないようね、諦めなさい。"
    end
  end
  
  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
