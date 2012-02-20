class BrowseController < ApplicationController
  load 'lib/pageshelper.rb'
  include PagesHelper

  def index
    setupPages()
    @servers = pagedResults(Server.find(:all),20)
    @sidebar_items = [{:text=>"Server List", :url=>{:action=>"index"}}]
  end

  def path
    setupPages()
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

    @entries = pagedResults(Entry.where("path = ?", params[:q]).order("folder DESC"),30);
  end

end
