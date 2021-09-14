class Student < ApplicationRecord
	def self.to_csv(options = {})
	    CSV.generate(options) do |csv|
	      csv << column_names
	      all.each do |student|
	        csv << student.attributes.values_at(*column_names)
	      end
	    end
  	end


	def self.import(file)
	  spreadsheet = open_spreadsheet(file)
	  header = spreadsheet.row(1)
	  (2..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	    student = find_by_id(row["id"]) || new
	    student.attributes = row.to_hash.slice(*row.to_hash.keys)
	    student.save!
	  end
	end

	def self.open_spreadsheet(file)
	  case File.extname(file.original_filename)
	   when '.csv' then Roo::Csv.new(file.path, nil, :ignore)
	   when '.xls' then Roo::Excel.new(file.path)
	   when '.xlsx' then Roo::Excelx.new(file.path)
	   else raise "Unknown file type: #{file.original_filename}"
	  end
	end

  
  def persisted?
    false
  end
  def load_imported_students
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(10)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      item = Item.find_by_id(row["id"]) || Item.new
      item.attributes = row.to_hash
      item
    end
  end

  def imported_students
    @imported_students ||= load_imported_students
  end

  def save
    if imported_students.map(&:valid?).all?
      imported_students.each(&:save!)
      true
    else
      imported_students.each_with_index do |item, index|
        item.errors.full_messages.each do |msg|
          errors.add :base, "Row #{index + 6}: #{msg}"
        end
      end
      false
    end
  end

end
