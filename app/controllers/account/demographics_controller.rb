class Account::DemographicsController < Account::ApplicationController
  include SortableActions
  account_load_and_authorize_resource :demographic, through: :team, through_association: :demographics

  # GET /account/teams/:team_id/demographics
  # GET /account/teams/:team_id/demographics.json
  def index
    delegate_json_to_api
  end

  # GET /account/demographics/:id
  # GET /account/demographics/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/demographics/new
  def new
  end

  # GET /account/demographics/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/demographics
  # POST /account/teams/:team_id/demographics.json
  def create
    respond_to do |format|
      if @demographic.save
        format.html { redirect_to [:account, @demographic], notice: I18n.t("demographics.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @demographic] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @demographic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/demographics/:id
  # PATCH/PUT /account/demographics/:id.json
  def update
    respond_to do |format|
      if @demographic.update(demographic_params)
        format.html { redirect_to [:account, @demographic], notice: I18n.t("demographics.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @demographic] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @demographic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/demographics/:id
  # DELETE /account/demographics/:id.json
  def destroy
    @demographic.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :demographics], notice: I18n.t("demographics.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
