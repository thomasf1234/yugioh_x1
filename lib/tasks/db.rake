namespace "db" do
  desc "creates the database for given ENV"
  task :create do
    file_name = "db_#{ENV['ENV']}"

    if File.exists?(file_name)
      puts "exiting because database '#{file_name}' already exists"
    else
      load('db/schema.rb')
      puts "created database '#{file_name}'"
    end
  end

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

  desc "resets the database for given ENV"
  task :reset do
    Rake::Task["db:drop"].execute
    Rake::Task["db:create"].execute
  end

  desc "backs up the database for given ENV to 'db/backups/<ENV>/<db_name>_<timestamp>.bak.gz'"
  task :backup do
    file_name = "db_#{ENV['ENV']}"
    backup_dir = "db/backups/#{ENV['ENV']}"
    FileUtils.mkdir_p(backup_dir)

    if File.exists?(file_name)
      backup_name = File.join(backup_dir, "#{file_name}_#{DateTime.now.utc.strftime("%Y%m%d%H%M%S")}.bak.gz")
      system("sqlite3 #{file_name} .dump | gzip -nc > #{backup_name}")
      exit_status = $?
      raise exit_status.inspect unless exit_status.exitstatus == 0
      puts "backed up '#{file_name}' to '#{backup_name}'"
    else
      puts "database '#{file_name}' not found"
    end
  end

  desc "restores the database for given ENV from passed gzipped archive .bak"
  task :restore, [:source]  do |t, args|
    db_name = "db_#{ENV['ENV']}"

    if File.exists?(db_name)
      puts "exiting because database '#{db_name}' already exists."
    else
      temp_copy = File.join('tmp', File.basename(args[:source]))
      system("cp #{args[:source]} #{temp_copy}")
      system("gunzip --force #{temp_copy}")
      unzipped_file = temp_copy.match(/.*\.bak/).to_s
      system("sqlite3 #{db_name} < #{unzipped_file}")
      FileUtils.rm(unzipped_file)
      puts "database '#{db_name}' restored"
    end
  end
  # https://rietta.com/blog/2013/11/28/rails-and-sql-views-for-a-report/
  # https://gist.github.com/jasoncodes/1307727
end