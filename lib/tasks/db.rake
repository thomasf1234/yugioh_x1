namespace "db" do
  desc "drops the database for given ENV"
  task :drop do
    file_name = "db_#{ENV['ENV']}"

    if File.exists?(file_name)
      File.delete(file_name)
      puts "database '#{file_name}' dropped"
    else
      puts "couldn't drop database '#{file_name}' because it does not exist"
    end
  end

  desc "backs up the database for given ENV to 'db/backups/<ENV>/<db_name>_<timestamp>.bak.gz'"
  task :backup do
    file_name = "db_#{ENV['ENV']}"
    backup_dir = "db/backups/#{ENV['ENV']}"
    FileUtils.mkdir_p(backup_dir)

    if File.exists?(file_name)
      backup_name = File.join(backup_dir, "#{file_name}_#{DateTime.now.utc.strftime("%Y%m%d%H%M%S")}.bak.gz")
      system("sqlite3 #{file_name} .dump | gzip -c > #{backup_name}")
      exit_status = $?
      raise exit_status.inspect unless exit_status.exitstatus == 0
      puts "backed up '#{file_name}' to '#{backup_name}'"
    else
      puts "database '#{file_name}' not found"
    end
  end
  # https://rietta.com/blog/2013/11/28/rails-and-sql-views-for-a-report/
  # https://gist.github.com/jasoncodes/1307727
end