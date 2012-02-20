class Entry < ActiveRecord::Base
  set_table_name "entries"
  has_many :children, :class_name => "Entry", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Entry"
  belongs_to :server, :class_name => "Server"

  MAX_DEPTH = 256

  load 'lib/myutil.rb'
  include MyUtil

  def setup()
    old_size = size
    old_created_at = created_at
#set up the search name field
    new_search_name = name()
#try to extract the extension
    if( not folder and (match = new_search_name.match("(.+)\\.([^\\.]+)$")) )
      new_search_name, self.extension = match.captures
    else
      self.extension = ""
    end
    new_search_name = new_search_name.downcase.gsub("[^a-z0-9]", "")
    self.extension.downcase!
    self.search_name = new_search_name
#set up created at and the size
    begin
#stating shares causes a segfault for me :/
      if not folder() then
        file_stat = SMB::File::Stat.stat("smb://#{path}/#{name}/")
        self.created_at = file_stat.mtime()
        if( file_stat.size() < 0 )
          self.size = file_stat.size().to_s + 2**32
        else
          self.size = file_stat.size().to_s
        end
      end
      rescue
        #server is probably down...
    end
    save()
    return old_size != size || old_created_at != created_at
  end

  def smb_update(depth)

    return false if depth > MAX_DEPTH

    if( folder() ) then
#will return true if there were changes, false otherwise
      new_size = 0
      has_changed = false
      smb_dir = nil
      begin
        smb_dir = SMB::Dir.open("smb://#{path}/#{name}/")
        rescue
          puts "Skipping '#{path}/#{name}'...."
          delete()
          return
      end

#create a hash for the names of entries that exist in this entry
      entries_to_update = {}
      smb_dir.to_a().each do |dir_entry|
        entries_to_update[dir_entry.name] = dir_entry
      end

#cycle through each of our existing children and update them
      for entry in children().find(:all) do
        if entries_to_update.has_key? entry.name then
          has_changed |= entry.smb_update(depth+1)
          new_size += entry.size().to_i
          entries_to_update.delete(entry.name)
        else
          entry.delete()
        end
      end

#cycle through the remaining entries that we haven't seen
      entries_to_update.keys().each do |entry_name|
        has_changed = true #if there are any new entries, then we have chagned
        dir_entry = entries_to_update[entry_name]
        if dir_entry.file? then
          begin
            new_entry = self.children.create(:name=>entry_name, :path=>path+"/"+name, :folder=>false)
            new_entry.setup
            new_entry.server=self.server
            new_size += new_entry.size().to_i
            rescue Exception => e
              puts "Skipping '#{path}/#{entry_name}'...."
              return
          end
        elsif dir_entry.dir? and !(dir_entry.name =~ /^\.{1,2}$/) then
          begin
            new_entry = self.children.create(:name=>entry_name, :path=>path+"/"+name, :folder=>true)
            new_entry.setup
            new_entry.server=self.server
            new_entry.smb_update(depth+1)
            new_size += new_entry.size().to_i
            rescue Exception => e
              puts "Skipping '#{path}/#{name}/#{entry_name}'...."
              return
          end
        end
      end

#update ourselves if there have been any changes
      if has_changed
        self.size = new_size.to_s
#stating shares seems to be bad
#if parent_id() != -1 then
        if not folder() then
          file_stat = SMB::File::Stat.stat("smb://#{path}/#{name}")
          self.created_at = file_stat.mtime()
        end
        save()
      end

      return has_changed
    else #if we are a file
      return self.setup #all we need to update is the size and modified time, which is handeled by setup
    end
      
  end

end
