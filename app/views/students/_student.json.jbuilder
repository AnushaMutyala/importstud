json.extract! student, :id, :name, :roll_no, :marks1, :marks2, :marks3, :avg, :created_at, :updated_at
json.url student_url(student, format: :json)
