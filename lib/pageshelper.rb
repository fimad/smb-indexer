module PagesHelper
  #Makes use of the get page param for current page

  def setupPages()
    @total_pages = 1
    @current_page= 1
  end

  def currentPage()
    page = params[:page].to_i
    return (page>=1) ? page : 1;
  end

  #takes a Object.find_by_sql function and an sql query
  #sets @current_page and @total_pages
  #returns results
  def pagedResults(results, perpage)

    @total_pages = (results.size().to_f/perpage).ceil
    @current_page = [currentPage(),@total_pages].min

    return results.slice((@current_page-1)*perpage, perpage)
  end
end

