require "json"
require "csv"

source_filename = ARGV[0]
puts "Opening #{source_filename}"
data = CSV.foreach(source_filename, headers: true).map do |row|
  row.headers.each_with_object({}) do |header, memo|
    memo[header] = row[header]
    if memo[header] != nil
      memo[header].strip!
    end
  end
end

dest_filename = File.join(File.dirname(source_filename), "#{File.basename(source_filename, File.extname(source_filename))}.json")
puts "Writing #{dest_filename}"
File.write(dest_filename, JSON.pretty_generate(data))

puts "Done"
