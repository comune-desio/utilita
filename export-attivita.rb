=begin
Use this against the CSV containing the dataset related to commercial activities.
=end

require "json"
require "csv"
require "set"

EXTRA_FIELDS = {
  "Facebook ID" => "",
  "Facebook URL" => "",
  "Google Place URL" => "",
  "Google Place ID" => "",
  "Latitude" => "",
  "Longitude" => "",
}

def item_from_row(row)
  result = row.to_h.merge(EXTRA_FIELDS)
  result["Categoria catastale"] = result["Categoria"].dup
  result["Categoria"] = ""
  result
end

csv_path = "mappatura attivita commercianti-artigiani-imprese desio.csv"
collection = CSV.foreach(csv_path, headers: :first_row).map do |row|
  item_from_row(row)
end

private_collection = []
public_collection = []
private_full_collection = []

PRIVATE_FIELDS = [
  "Telefono",
  "Codice Fiscale",
  "e-mail",
].to_set

collection.each do |item|
  public_collection << item.reject do |key, value|
    PRIVATE_FIELDS.include?(key)
  end

  private_collection << item.select do |key, value|
    key == "UUID" || PRIVATE_FIELDS.include?(key)
  end

  private_full_collection << item
end

def dump_to_json(filename:, collection:)
  File.write(filename, JSON.pretty_generate(collection))
end

def dump_to_csv(filename:, collection:)
  CSV.open(filename, "wb") do |csv|
    csv << collection[0].keys
    collection[1..-1].each do |item|
      csv << item.values
    end
  end
end

dump_to_json(filename: "attivita-public.json", collection: public_collection)
dump_to_json(filename: "attivita-private.json", collection: private_collection)
dump_to_json(filename: "attivita-private-full.json", collection: private_full_collection)

dump_to_csv(filename: "attivita-public.csv", collection: public_collection)
dump_to_csv(filename: "attivita-private.csv", collection: private_collection)
dump_to_csv(filename: "attivita-private-full.csv", collection: private_full_collection)
