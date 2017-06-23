# -*- encoding : utf-8 -*-

require_relative "../../script/csv_import/wikipedia/wikipedia_csv_row"
require_relative "../../script/csv_import/csv_file"

class UpdateWikipediaMapping < Card::Migration
  disable_ddl_transaction!

  def up
    csv_path = data_path "wikirate_to_wikipedia.csv"
    CSVFile.new(csv_path, WikipediaCSVRow)
           .import user: "Vasiliki Gkatziaki",  error_policy: :report
  end
end
