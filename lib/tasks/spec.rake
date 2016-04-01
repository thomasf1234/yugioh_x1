namespace "spec" do
  desc "download_stub"
  task :download_stub, [:url]  do |t, args|
    destination = "spec/samples/db/card_data_fetcher/stubs/#{args[:url].strip.split('/').last}"
    File.open(destination, 'wb') do |file|
      file.write open(args[:url]).read
    end

    puts "Downloaded to: '#{destination}'"
  end
end