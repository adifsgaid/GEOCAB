class UsersController < ApplicationController
  before_action :current, only: [:edit, :update]
  before_action

  def edit
  end

  def update
    if current_user.budget.nil?
      @user.update(user_params)
      redirect_to questionnaire2_searches_path

    elsif current_user.budget.zero?
      @user.update(user_params)
      redirect_to questionnaire2_searches_path

    else
      @user.update(user_params)
      redirect_to dashboard_path
    end
  end

  def mes_locaux
    @search = current_user.searches.last
    @ads = Ad.near([@search.latitude, @search.longitude], 10)
    # the `geocoded` scope filters only flats with coordinates (latitude & longitude)
    @competitors = []
    @markers = @ads.map do |ad|
      # markerCompetitor

      @places = current_user.search_places
      @competitors += Competitor.near([ad.latitude, ad.longitude], 10)

      {
        lat: ad.latitude,
        lng: ad.longitude,
        infoWindow: render_to_string(partial: "/shared/info_window", locals: { ad: ad }),
        image_url: helpers.asset_url("marker.png"),
        id: ad.id
      }
    end

    @markers_competitors = @competitors.uniq.map do |competitor|
      {
        lat: competitor.latitude,
        lng: competitor.longitude,
        id: competitor.id,
        image_url: helpers.asset_url('competitor_marker.png')
      }
    end
  end

  def mes_locaux_submit
    redirect_to mes_locaux
  end

  def chiffres_cles
    @ad = Ad.all
    @avg = @ad.map(&:rent_cents).sum / @ad.length.to_f
    @places = current_user.search_places
    @search = current_user.post_search
  end


  def current
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:job, :ordre, :cpam, :urssaf, :retraite, :assurance_rcp, :budget, :cabinet, :materiel, :doctolib, :google_business)
  end
end
