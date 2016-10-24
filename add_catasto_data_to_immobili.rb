require "open-uri"
require "json"

def blank?(value)
  value == nil || value == ""
end

def any_blank?(list)
  list.any? do |value|
    blank?(value)
  end
end

source_filename = ARGV[0]
if !File.exist?(source_filename)
  puts "Error: #{source_filename} doesn't exist."
  exit(0)
end

CITY_CODES = {
  "desio" => "286"
}

def build_api_url(foglio:, mappale:, city_code:)
  "http://www.cartografia.regione.lombardia.it/ArcGIS10P/rest/services/wsGazetteer/wsGazetteerGen/MapServer/6/query?returnGeometry=true&spatialRel=esriSpatialRelIntersects&f=json&where=id_gaz%3D%27D286-#{foglio}-#{mappale}%27&outFields=FOGLIO%2CCODICE_BELFIORE%2CNUMERO&outSR=4326"
end

cache_table = {}

data = JSON.parse(File.read(source_filename))
total = data.count
puts "Processing #{total} records"
skipped_records = []
data.map!.with_index do |record, index|
  city_name = (record["LOCALITA'"] || "").downcase.strip
  foglio = record["FG"]
  mappale = record["MAPPALE"]
  city_code = CITY_CODES[city_name]
  print "#{index + 1}/#{total}: [foglio=#{foglio}] [mappale=#{mappale}] [city_code=#{city_code}]: "
  if any_blank?([city_code, foglio, mappale])
    puts "Skipping record because at least one of the required fields is missing."
    skipped_records << record
  else
    cache_key = "#{city_code}_#{foglio}_#{mappale}"
    catasto_data = if cache_table.has_key?(cache_key)
      puts "[cache:HIT]"
      cache_table[cache_key]
    else
      puts "[cache:MISS]"
      url = build_api_url(foglio: foglio, mappale: mappale, city_code: city_code)
      cache_table[cache_key] = JSON.parse(open(url).read)
    end
    record["catasto_data"] = cache_table[cache_key]["features"]
  end
  record
end

def filename_with_suffix(filename:, suffix:)
  dirname = File.dirname(filename)
  ext_name = File.extname(filename)
  basename = File.basename(filename, ext_name)
  File.join(dirname, "#{basename}#{suffix}#{ext_name}")
end

skipped_filename = filename_with_suffix(filename: source_filename, suffix: "--skipped")
File.write(skipped_filename, JSON.pretty_generate(skipped_records))

dest_filename = filename_with_suffix(filename: source_filename, suffix: "--with-catasto-data")
File.write(dest_filename, JSON.pretty_generate(data))
puts "Done"
