require 'test/unit'
require 'json'
require_relative 'challenge'

class ChallengeTest < Test::Unit::TestCase


    def teardown
        if File.exist?("output.txt")
            File.delete("output.txt")
        end
    end


    def test_01_pass_read_json
        testArr = [{"key1" => "value1"}]
        File.open("sample.json", "w") do |file|
            file.puts JSON.pretty_generate(testArr)
        end

        resultArr = read_json("sample.json")
        assert_equal(testArr, resultArr)
        File.delete("sample.json")
    end


    def test_02_fail_read_json
        testArr = [{"key1": "value1"}]
        File.open("sample.json", "w") do |file|
            json_str = JSON.pretty_generate(testArr)
            bad_json_str = json_str[0..-2]
            file.puts bad_json_str
        end
        assert_raise(
            StandardError,
            "Error parsing JSON data from file 'sample.json': unexpected token at ''") \
        do
            read_json("sample.json")
        end
        File.delete("sample.json")
    end


    def test_03_fail_read_json
        assert_raise(
            StandardError,
            "File 'bad_file.json' does not exist.") \
        do
            read_json("bad_file.json")
        end
    end


    def test_04_pass_validate_companies
        companies = [{
            "id" => 1,
            "name" => "Test company",
            "top_up" => 12,
            "email_status" => false
        }]

        assert_nothing_raised { validate_companies(companies) }
    end


    def test_05_fail_validate_companies
        companies = "Some bad string"
        assert_raise(
            StandardError,
            "'#{COMPANIES_FILE_PATH}' does not have a valid JSON array.") \
        do
            validate_companies(companies)
        end
    end


    def test_06_fail_validate_companies
        companies = ["should be a hash instead"]
        assert_raise(
            StandardError,
            "company array does not have JSON objects.") \
        do
            validate_companies(companies)
        end
    end


    def test_07_fail_validate_companies
        companies = [{
            "id" => 1,
            "name" => "Test company",
            "top_up" => 12,
            "email_status" => false,
            "some_bad_key" => 2
        }]
        assert_raise(
            StandardError,
            "JSON object for a company has illegal key: `some_bad_key`.") \
        do
            validate_companies(companies)
        end
    end


    def test_08_fail_validate_companies
        companies = [{
            "id" => "ABC",
            "name" => "Test company",
            "top_up" => 12,
            "email_status" => false
        }]
        assert_raise(
            StandardError,
            "JSON object for company has key 'id' with illegal value.") \
        do
            validate_companies(companies)
        end
    end


    def test_09_pass_validate_users
        users = [{
            "id" => 123,
            "first_name" => "John",
            "last_name" => "Smith",
            "email" => "john.smith@example.com",
            "company_id" => 45,
            "email_status" => true,
            "active_status" => false,
            "tokens" => 34
        }]
        assert_nothing_raised { validate_users(users) }
    end


    def test_10_fail_validate_users
        users = ["should be a hash instead"]
        assert_raise(StandardError, "user array does not have JSON objects.") \
        do
            validate_users(users)
        end
    end


    def test_11_fail_validate_users
        users = [{
            "id" => 123,
            "first_name" => "John",
            "last_name" => "Smith",
            "email" => "john.smith@example.com",
            "company_id" => 45,
            "email_status" => true,
            "active_status" => false,
            "tokenzzz" => 34
        }]
        assert_raise(
            StandardError,
            "JSON object for a user has illegal key: 'tokenzzz'.") \
        do
            validate_users(users)
        end
    end


    def test_12_fail_validate_users
        users = [{
            "id" => 123,
            "first_name" => "John",
            "last_name" => "Smith",
            "email" => "john.smith@example.com",
            "company_id" => 45,
            "email_status" => true,
            "active_status" => "false",
            "tokens" => 34
        }]
        assert_raise(
            StandardError,
            "JSON object for user has key 'active_status' with illegal value.") \
        do
            validate_users(users)
        end
    end
end
