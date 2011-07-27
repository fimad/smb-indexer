class SearchController < ApplicationController
  def index
    @online_now = Server.find(:all, :order=>"name ASC")
  end

  def result_page(offset, limit)
    terms = params[:query].split(" ")
    where_clause = (terms.map {|q| "(search_name LIKE '%#{q}%')" }).join("AND")

    relevance_clause = (terms.map {|q| "IF((search_name LIKE '%#{q}%'),1,0)" }).join("+")
    relevance_clause = "(#{relevance_clause})/LENGTH(search_name) as relevance"

    @my_results = Entry.find_by_sql("SELECT *, #{relevance_clause} FROM `entries` WHERE #{where_clause} ORDER BY relevance DESC LIMIT #{limit} OFFSET #{offset}")
  end

  def results
    if( params[:query].size < 3 )
      @too_short = 1
    else
      result_page(0, 20)
    end
  end

end
