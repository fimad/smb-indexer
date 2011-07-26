class BrowseController < ApplicationController
  def index
    @servers = Server.find(:all)
    @sidebar_items = [{:text=>"Server List", :url=>{:action=>"index"}}]
  end

  def path
    @sidebar_items = [{:text=>"Server List", :url=>{:action=>"index"}}]
    path = ""
    id = 0
    params[:q].split("/").each do |item|
      if path.empty?
        path = item
      else
        path += "/#{item}"
      end
      @sidebar_items.push({:text=>item, :id=>id, :url=>{:action=>"path",:q=>path}});
      id += 1
    end

    @entries = Entry.where("path = ?", params[:q]).order("folder DESC");
  end

end
