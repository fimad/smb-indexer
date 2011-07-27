module MyUtil
  def fancy_size()
    sufix = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    formatted_size = self.size().to_f
    while( formatted_size > 1024 ) do
      sufix.shift
      formatted_size/=1024
    end
    return "%.2f #{sufix[0]}" % formatted_size
  end
end
