class SearchController < ApplicationController
  def index
    @online_now = Server.find(:all)
  end

  def results
    @my_results = Entry.where("search_name like ?", "%#{params[:query]}%")
  end

end
