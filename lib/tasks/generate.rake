namespace "generate" do
  desc "generates template migration"
  task :migration, [:name]  do |t, args|
contents = <<EOF
class #{args[:name].camelize} < ActiveRecord::Migration
  def self.up
  end

  def self.down
  end
end
EOF
    file_name = "#{DateTime.now.utc.strftime("%Y%m%d%H%M%S")}_#{args[:name]}.rb"
    File.open(File.join("db/migrate", file_name), 'w') do |file|
      file.write(contents)
    end

    puts "created template migration '#{File.join("db/migrate", file_name)}'"
  end
end