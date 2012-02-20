module ClauseHelper
#generate a clause that will match the given extensions
  def clauseForExts(exts)
    return " AND ("+exts.map{ |e| "(extension = '#{e}')"}.join(" OR ") +")"
  end
end

