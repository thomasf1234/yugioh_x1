require 'open-uri'

module Utilities
  def retry_task(times=1)
    i = -1

    begin
      yield
    rescue => e
      i += 1
      retry if i < times
    end
  end

  def retry_open(url, times=1)
    retry_task(times) { open(url) }
  end
end