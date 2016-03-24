# Uso: ruby csv2geojson.rb file.csv

require "csv"
require "json"

path = ARGV[0]

features = CSV.foreach(path, col_sep: ",", headers: true).map do |row|
  title = "#{row["name"]}, #{row["TOPONIMO"]} #{row["INDIRIZZO"]} #{row["CIVICO"]}"
  {
    type: "Feature",
    geometry: {
      type: "Point",
      coordinates: [
        row["longitude"],
        row["latitude"],
      ]
    },
    properties: {
      title: title,
      description: row["DESCRIZIONE"],
      "marker-symbol": "heart",
      "marker-color": "#E56C69",
    }
  }
end

document = {
  type: "FeatureCollection",
  features: features
}

dest_filename = "#{File.basename(path, ".csv")}.geojson"

File.write(dest_filename, JSON.pretty_generate(document))
