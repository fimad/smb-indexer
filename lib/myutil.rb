module MyUtil
  def fancy_size()
    sufix = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    formatted_size = self.size().to_i
    while( formatted_size > 1024 ) do
      sufix.shift
      formatted_size/=1024
    end
    return "#{formatted_size}#{sufix[0]}"
  end
end
