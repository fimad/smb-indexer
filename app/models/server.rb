require 'smb'

class Server < ActiveRecord::Base
  has_many :entries, :class_name => "Entry", :conditions => "parent_id = -1"

  MIN_SERVER_SIZE = 1024**3 #the must be sharing a gig to be considered a file sharing server

  load 'lib/myutil.rb'
  include MyUtil

  def self.find_new_servers()
    SMB::Dir.foreach("smb://") do |workgroup|
      begin
        SMB.open("smb://#{workgroup}/").to_a().each do |dir_ent|
          if dir_ent.server? and Server.file_sharing_server?(dir_ent.name) and Server.where("name = ?", dir_ent.name).empty? then
            new_server = Server.create(:name=>dir_ent.name(), :online=>true, :size=>"0")
            new_server.save()
          end
        end
        rescue
          puts "Skipping 'smb://#{workgroup}/'..."
      end
    end
  end

  def self.remove_small_servers()
    Server.find(:all).each { |server| server.destroy() if server.size().to_i < MIN_SERVER_SIZE }
  end

  def self.quick_update_all_servers()
    for server in Server.find(:all) do
      server.refresh_ip
      server.refresh_online
      server.save
    end
  end

  def self.update_all_servers()
    for server in Server.find(:all) do
      puts "Working on '#{server.name}'..."
      server.smb_update()
    end
  end

  def refresh_online()
    SMB.open("smb://#{name}/")
    self.online = true
    rescue
      self.online = false
  end

  def refresh_ip()
    escaped_name = name()
    escaped_name.gsub("['\\]", "") #remove ' from the name
    IO.popen("nmblookup #{escaped_name}") do |io| #unfortunately smbclient doesn't give you the ip address so we must use nmblookup to find it
      result_line = ""
      #the last line is the only one we want, everything before is logging info
      io.each_line { |line| result_line = line }
      if( match = result_line.match("^([0-9\.]+) ") )
        self.ip = match.captures[0]
      end
    end
    rescue
      #do nothing, we can't get the ip
      self.ip = "-"
  end

  def smb_update()
    new_size = 0
    smb_server = nil 
    begin
#this will throw an exception and crash if the server is not online
      smb_server = SMB::Dir.open("smb://#{name()}")
      rescue
        return
    end

#will attempt to update all the entries belonging to this server
#create a hash of all the entries present in this directory
    entries_to_update = {}
    smb_server.to_a.each do |dir_entry|
      entry_name = dir_entry.name
      entries_to_update[entry_name] = dir_entry
    end


#iterate over all of the entries we have so far and update them if they are in the hash, delete otherwise
    for entry in self.entries().find(:all) do
      if entries_to_update.has_key? entry.name 
        entry.smb_update(0)
        if entries_to_update.delete(entry.name) == nil 
        end
        new_size += entry.size().to_i;
      else
        entry.delete()
      end
#clear the Entry cache after each share on the server
      Entry.connection.clear_query_cache()
    end

#iterate over each new share and create a new entry for it
    entries_to_update.keys.each do |entry_name|
      dir_entry = entries_to_update[entry_name]
      if( dir_entry.file_share? )
        begin
          new_entry = entries().create(:name => entry_name, :path => name, :folder => true, :parent_id => -1)
          new_entry.setup
          new_entry.smb_update(0)
          new_size += new_entry.size().to_i;
          rescue Exception => e
            puts "Skipping smb://#{name}/#{entry_name}..."
            new_entry.delete()
          end
      end
    end

#update ourself
    self.online = true
    self.size = new_size.to_s
#try to look up the ip address of the server
    refresh_ip
    
#save ourselves!
    save()
  end


#based on the name of this server, is it likely that it is a file sharing server
  def self.file_sharing_server?(name)
    return (name.length > 1 and !(name =~ /[0-9]+-[0-9]+/) and !(name =~ /[\-_](DELL|THINK|ALIEN)$/) and !(name =~ /MACBOOK/) and !(name =~ /-PC[0-9]*/) and !(name =~ /\-(LAPTOP|COMPUTER)/) and !(name =~ /[a-zA-Z]{2,3}[0-9]{5,6}/))
  end

end
