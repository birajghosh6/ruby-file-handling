# JSON Processing with Ruby

This Ruby script processes JSON files containing user and company data to generate an output file with some specific instructions as outlined in `challenge.txt`. It handles token top-ups for active users, emailing based on company and user email statuses, and orders the output by `company_id` and user `last_name`.

## Requirements

- Ruby installed on your system. You can download it from [https://www.ruby-lang.org/en/downloads/](https://www.ruby-lang.org/en/downloads/)
- Ensure Ruby is added to the system PATH.

To confirm Ruby works, open up a terminal and try
```
ruby --version
```

## Setup

1. **Clone the Repository:**

   Clone this repository to your local machine:
    ```
    git clone https://github.com/birajghosh6/ruby-file-handling.git
    ```

2. **Navigate to the Project Directory:**
    ```
    cd ruby-file-handling
    ```

4. **JSON File Setup:**

    - Ensure you have the following JSON files:
    - `companies.json`: Contains company data.
    - `users.json`: Contains user data.
    - Place these files in the root directory of the project.

## Usage

1. **Run the Script:**

    Execute the Ruby script `challenge.rb` from the command line:
    ```
    ruby challenge.rb
    ```
    
    This will generate an `output.txt` file in the project directory with the processed data.

2. **Review Output:**

    Open the `output.txt` file to view the processed data according to the specified criteria. The 
    code is written as per requirements set in the `challenge.txt` file.

## Testing

Unit tests are included to ensure the correctness of the script. You can run these tests using the following steps:

1. **Run Unit Tests:**

   Execute the unit tests by running the following command in your terminal:
   ```
   ruby challenge_test.rb
   ```


