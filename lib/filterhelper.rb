module FilterHelper
  load 'lib/clausehelper.rb'
  include ClauseHelper

  def filterToClause
    return {
      "Everything"=>"",
      "Folders"=>" AND (folder = 1)",
      "Video"=>clauseForExts(["3g2","3gp","asf","asx","avi","flv","mov","mp4","mpeg","mpg","rm","swf","vob","wmv"]),
      "Audio"=>clauseForExts(["aif","iff","m3u","m4a","mid","mp3","mpa","ra","wav","wma","ogg","flac"]),
      "Applications"=>clauseForExts(["app","bat","cgi","com","exe","jar","pif","vb","wsf","rb","py","pl","sh","bin"]),
      "Images"=>clauseForExts(["raw","bmp","gif","jpg","jpeg","png","psd","pspimage","thm","tif","tiff","yuv","ai","drw","eps","ps","svg"]),
      "ISO's"=>clauseForExts(["dmg","iso","toast","vcd","bin","cue","img","qcow","qcow2","hdd","vdmk","vmdk"]),
      "Text/Ebooks"=>clauseForExts(["pdf","txt","htm","html","iba","azw","kf8","aeh","lrf","lrx","cbr","cbz","cb7","cbt","cba","chm","dnl","djvu","epub","pdb","fb2","xeb","ceb","lit","prc","mobi","opf","ps","pdb"]),
      "Archives"=>clauseForExts(["7z","deb","gz","pkg","rar","rpm","sit","sitx","tar","tgz","bz2","zip","zipx"])
    }
  end

  def getFilter()
    return (filterToClause().keys.count(params[:filter])>0) ? params[:filter] : "Everything";
  end

  def getFilterClause()
    return filterToClause()[getFilter()]
  end

  def setupFilter()
    @filter = getFilter()
  end

end
