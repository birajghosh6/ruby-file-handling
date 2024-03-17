require 'json'

COMPANIES_FILE_PATH = "companies.json"
USERS_FILE_PATH = "users.json"


#  This method is used to accept the path of a json file and parse its contents into an Array.
#
#  Parameters
#  --
#  - `file_path`: This is the path of the file that contains the json arrays.
#
#  Returns
#  --
#  The array parsed from the .json file.
def read_json(file_path)
   unless File.exist?(file_path)
      raise StandardError, "File '#{file_path}' does not exist."
   end

   begin
      json_data = File.read(file_path)
   rescue StandardError => e
      raise StandardError, "Error reading file '#{file_path}' #{e.message}"
   end

   # Parse JSON data into a data structure
   begin
      json_object = JSON.parse(json_data)
   rescue JSON::ParserError => e
      raise StandardError, "Error parsing JSON data from file '#{file_path}': #{e.message}"
   end

   return json_object
end


#  This method is used to accept company and user information for the company, and format it in a specific manner to
#  write to an output file.
#
#  Parameters
#  --
#  - `company_id`: The id of the company.
#  - `company_name`: The name of the company.
#  - `users_emailed`: An array of users of the company that have been emailed.
#  - `users_not_emailed`: An array of users of the company that have been not been emailed.
#  - `total_top_ups`: The total top ups of the company.
#
#  Returns
#  --
#  A formatted string with information about the company and its users.
def get_formatted_company_with_user_info(company_id, company_name, users_emailed, users_not_emailed, total_top_ups)
   company_details = ""

   company_details += "\tCompany Id: #{company_id}\n"
   company_details += "\tCompany Name: #{company_name}\n"

   company_details += "\tUsers Emailed:\n"
   users_emailed_details = ""
   for user in users_emailed
      company_details += "\t\t#{user["last_name"]}, #{user["first_name"]}, #{user["email"]}\n"
      company_details += "\t\t\tPrevious Token Balance, #{user["tokens"]}\n"
      company_details += "\t\t\tNew Token Balance #{user["tokens_updated"]}\n"
   end

   company_details += "\tUsers Not Emailed:\n"
   for user in users_not_emailed
      company_details += "\t\t#{user["last_name"]}, #{user["first_name"]}, #{user["email"]}\n"
      company_details += "\t\t\tPrevious Token Balance, #{user["tokens"]}\n"
      company_details += "\t\t\tNew Token Balance #{user["tokens_updated"]}\n"
   end

   company_details += "\t\tTotal amount of top ups for #{company_name}: #{total_top_ups}\n\n"

   return company_details
end


#  This method is used to create a hash of companies where
#  key: company_id and value: company information and empty user information
#
#  Parameters
#  --
#  - `companies`: The array of companies obtained from the companies json file.
#
#  Returns
#  --
#  A hash of companies with empty user information, with company_id as the key of the hash.
def initialize_companies_hash(companies)

   output_companies_hash = Hash.new

   for company in companies
      company_id = company["id"]
      output_companies_hash[company_id] = Hash.new
      output_companies_hash[company_id]["company_id"] = company_id
      output_companies_hash[company_id]["company_name"] = company["name"]
      output_companies_hash[company_id]["email_status"] = company["email_status"]
      output_companies_hash[company_id]["users_emailed"] = []
      output_companies_hash[company_id]["users_not_emailed"] = []
      output_companies_hash[company_id]["top_up"] = company["top_up"]
      output_companies_hash[company_id]["total_top_ups"] = 0
   end

   return output_companies_hash
end


#  This method is used to get an array of company information, each containing information about its users.
#
#  Parameters
#  --
#  - `users`: Contains an array of users and their information, including their company_id
#  - `companies`: Contains an array of companies and their information
#
#  Returns
#  --
#  Array of companies with company and user information for each company, pertaining to emailing, and top ups
def get_companies_with_user_info(users, companies)

   companies_hash = initialize_companies_hash(companies)

   for user in users

      company_id = user["company_id"]

      user["tokens_updated"] = user["tokens"] + companies_hash[company_id]["top_up"]
      companies_hash[company_id]["total_top_ups"] += companies_hash[company_id]["top_up"]

      if companies_hash[company_id]["email_status"] && user["email_status"]
         companies_hash[company_id]["users_emailed"] << user
      else
         companies_hash[company_id]["users_not_emailed"] << user
      end
   end

   return companies_hash.values
end


#  This method is used to accept an array of companies with user information, and write them to a file.
#
#  Parameters:
#  --
#  - `companies_with_user_info`: This is the array of companies, containing company and user information
#                                to write to a file.
def write_company_details_to_file(companies_with_user_info)

   File.open("output.txt", "w") do |file|

      for company  in companies_with_user_info
         formatted_company_with_user_info = get_formatted_company_with_user_info(
            company["company_id"],
            company["company_name"],
            company["users_emailed"],
            company["users_not_emailed"],
            company["total_top_ups"]
         )
         file.puts formatted_company_with_user_info
      end
   end
end


#  This method is used to validate companies array and ensure that the entries in the JSON objects have the
#  right data types.
#
#  Parameters
#  --
#  - `companies`: The json array of companies.
def validate_companies(companies)

   unless companies.is_a?(Array)
      raise StandardError, "'#{COMPANIES_FILE_PATH}' does not have a valid JSON array."
   end

   for company in companies

      unless company.is_a?(Hash)
         raise StandardError, "company array does not have JSON objects."
      end

      legal_keys = ["id", "name", "top_up", "email_status"]
      company.each_pair do |key, value|

         unless legal_keys.include?(key)
            raise StandardError, "JSON object for a company has illegal key: `#{key}`."
         end

         illegal_key = ""
         case key
         when "id"
            unless value.is_a?(Integer)
               illegal_key = "id"
            end
         when "name"
            unless value.is_a?(String)
               illegal_key = "name"
            end
         when "top_up"
            unless value.is_a?(Integer)
               illegal_key = "top_up"
            end
         when "email_status"
            unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
               illegal_key = "email_status"
            end
         end

         unless illegal_key == ""
            raise StandardError, "JSON object for company has key '#{illegal_key}' with illegal value."
         end

      end

   end
end


#  This method is used to validate users array and ensure that the entries in the JSON objects have the
#  right data types.
#
#  Parameters
#  --
#  - `users`: The json array of users.
def validate_users(users)

   unless users.is_a?(Array)
      raise StandardError, "'#{USERS_FILE_PATH}' does not have a valid JSON array."
   end

   for user in users

      unless user.is_a?(Hash)
         raise StandardError, "user array does not have JSON objects."
      end

      legal_keys = ["id", "first_name", "last_name", "email", "company_id", "email_status", "active_status", "tokens"]
      user.each_pair do |key, value|

         unless legal_keys.include?(key)
            raise StandardError, "JSON object for a user has illegal key: '#{key}'."
         end

         illegal_key = ""
         case key
         when "id"
            unless value.is_a?(Integer)
               illegal_key = "id"
            end
         when "first_name"
            unless value.is_a?(String)
               illegal_key = "first_name"
            end
         when "last_name"
            unless value.is_a?(String)
               illegal_key = "last_name"
            end
         when "email"
            unless value.is_a?(String)
               illegal_key = "email"
            end
         when "company_id"
            unless value.is_a?(Integer)
               illegal_key = "company_id"
            end
         when "email_status"
            unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
               illegal_key = "email_status"
            end
         when "active_status"
            unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
               illegal_key = "active_status"
            end
         when "tokens"
            unless value.is_a?(Integer)
               illegal_key = "tokens"
            end
         end

         unless illegal_key == ""
            raise StandardError, "JSON object for user has key '#{illegal_key}' with illegal value."
         end
      end
   end
end


#  This method is used to parse two json files, one for companies and one for users,
#  and create a file output.txt which contains some calculated information based on the
#  the two input files.
def process_json_files

   begin
      companies = read_json(COMPANIES_FILE_PATH)
      validate_companies(companies)
      # ascending sort by id of each company.
      companies = companies.sort_by {|hash| hash["id"]}
      company_ids = companies.map { |company| company["id"] }

      users = read_json(USERS_FILE_PATH)
      validate_users(users)
      # filter out users for which there exists no company details
      users = users.select { |user| company_ids.include?(user["company_id"]) && user["active_status"] }
      # ascending sort by company_id for each user.
      users = users.sort_by {|user_hash| [user_hash["company_id"], user_hash["last_name"]]}

      companies_with_user_info = get_companies_with_user_info(users, companies)

      write_company_details_to_file(companies_with_user_info)
   rescue StandardError => e
      puts e.message
   end
end

process_json_files()
