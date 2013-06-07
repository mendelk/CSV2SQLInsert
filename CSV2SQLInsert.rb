#!/usr/bin/env ruby

require 'csv'

csv_file = ARGV[0]
basename = File.basename csv_file, '.csv'

seperator = ARGV[1] || ','

raise 'You mass pass the CSV file as an arg' if csv_file.nil?

csv_text = File.read(csv_file)
# csv_text = csv_text.gsub(/(?<!\\)""/,'\\"') # converts "" to \"

csv = CSV.parse(csv_text, :col_sep => seperator, :headers => true, :write_headers => false, :force_quotes => true)

raise "You'll need header for this to work!" if csv.headers.nil?

output = "INSERT INTO #{basename} \n"
output << "  (" + csv.headers.join(', ') + ") \n"
output << "VALUES \n"
# puts csv.methods
csv.each_with_index do |row,index|
  output << '  ("'
  tmp_arr = []
  row.each do |field|
    tmp_arr << field.last.gsub(/"/,'""')
  end
  output << tmp_arr.join('","')
  output << '")' + (index < csv.size-1 ? ',' : ';') + " \n"
end

File.open(basename + '.sql', 'w') {|f| f.write(output) }

