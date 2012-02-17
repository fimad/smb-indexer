class SearchController < ApplicationController

#generate a clause that will match the given extensions
  def SearchController.clauseForExts(exts)
    return " AND ("+exts.map{ |e| "(extension = '#{e}')"}.join(" OR ") +")"
  end
  @@filterToClause = {
    "All"=>"",
    "Folders"=>" AND (folder = 1)",
    "Video"=>clauseForExts(["3g2","3gp","asf","asx","avi","flv","mov","mp4","mpeg","mpg","rm","swf","vob","wmv"]),
    "Audio"=>clauseForExts(["aif","iff","m3u","m4a","mid","mp3","mpa","ra","wav","wma","ogg","flac"]),
    "Applications"=>clauseForExts(["app","bat","cgi","com","exe","jar","pif","vb","wsf","rb","py","pl","sh","bin"]),
    "Images"=>clauseForExts(["raw","bmp","gif","jpg","jpeg","png","psd","pspimage","thm","tif","tiff","yuv","ai","drw","eps","ps","svg"]),
    "ISO's"=>clauseForExts(["dmg","iso","toast","vcd","bin","cue","img","qcow","qcow2","hdd","vdmk","vmdk"]),
    "Text/Ebooks"=>clauseForExts(["pdf","txt","htm","html","iba","azw","kf8","aeh","lrf","lrx","cbr","cbz","cb7","cbt","cba","chm","dnl","djvu","epub","pdb","fb2","xeb","ceb","lit","prc","mobi","opf","ps","pdb"]),
    "Archives"=>clauseForExts(["7z","deb","gz","pkg","rar","rpm","sit","sitx","tar","tgz","bz2","zip","zipx"])
  }

  def index
    @online_now = Server.find(:all, :order=>"name ASC")
  end

  def getFilter()
    return (@@filterToClause.keys.count(params[:filter])>0) ? params[:filter] : "All";
  end

  def getFilterClause()
    return @@filterToClause[getFilter()]
  end

  def result_page(offset, limit)
    #build the fuzzy searching query
    terms = params[:query].split(" ")
    where_clause = (terms.map {|q| "(search_name LIKE '%#{q}%')" }).join("AND") + getFilterClause()

    relevance_clause = (terms.map {|q| "IF((search_name LIKE '%#{q}%'),1,0)" }).join("+")
    relevance_clause = "(#{relevance_clause})/LENGTH(search_name) as relevance"

    @my_results = Entry.find_by_sql("SELECT *, #{relevance_clause} FROM `entries` WHERE #{where_clause} ORDER BY relevance DESC LIMIT #{limit} OFFSET #{offset}")
  end

  def results
    @filter = getFilter()

    if( params[:query].size < 3 )
      @too_short = 1
    else
      result_page(0, 20)
    end
  end

end
