class SearchController < ApplicationController
  load 'lib/filterhelper.rb'
  load 'lib/pageshelper.rb'
  include FilterHelper
  include PagesHelper

  def index
    @online_now = Server.find(:all, :order=>"name ASC")
  end

  def result_page()
    setupFilter()

    #build the fuzzy searching query
    terms = params[:query].split(" ")
    where_clause = (terms.map {|q| "(search_name LIKE '%#{q}%')" }).join("AND") + getFilterClause()

    relevance_clause = (terms.map {|q| "IF((search_name LIKE '%#{q}%'),1,0)" }).join("+")
    relevance_clause = "(#{relevance_clause})/LENGTH(search_name) as relevance"

    @my_results = pagedResults(Entry.find_by_sql("SELECT *, #{relevance_clause} FROM `entries` WHERE #{where_clause} ORDER BY relevance DESC "), 20)
#    @my_results = pagedResults( lambda{|a| Entry.find_by_sql(a)}, "SELECT *, #{relevance_clause} FROM `entries` WHERE #{where_clause} ORDER BY relevance DESC", 20)
  end

  def results
    setupFilter()
    setupPages()

    if( params[:query].strip.size < 3 )
      @too_short = 1
    else
      result_page()
    end
  end

end
