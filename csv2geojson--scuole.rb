# Uso: ruby csv2geojson.rb file.csv

require "csv"
require "json"

path = ARGV[0]

if !File.exists?(path)
  puts "File #{path} doesn't exist, exiting."
  exit 1
end

features = CSV.foreach(path, col_sep: ",", headers: true).map do |row|
  {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [
        row["longitudine"],
        row["latitudine"],
      ]
    },
    properties: {
      name: row["Nome"],
      address: row["Indirizzo"],
      telephone: row["Telefono"],
      email: "<a href=\"mailto:#{row["E-mail"]}\">#{row["E-mail"]}</a>",
      site: "<a href=\"#{row["Sito"]}\" target=\"_BLANK\">#{row["Sito"]}</a>",
      note: row["Note"],
      "marker-symbol": "college",
      "marker-color": "#00AF64",
    }
  }
end

document = {
  type: "FeatureCollection",
  features: features
}

dest_filename = "#{File.basename(path, ".csv")}.geojson"

File.write(dest_filename, JSON.pretty_generate(document))
