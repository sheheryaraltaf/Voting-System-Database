import random
import pyodbc as odbc
from faker import Faker

# Initialize Faker with the Indian English locale
f = Faker('en_IN')

# Define a custom provider for Pakistani male and female names
class PakistaniNameProvider:
    def __init__(self, faker):
        self.faker = faker

    def pakistani_male_name(self):
        return random.choice(pakistani_male_names)

    def pakistani_female_name(self):
        return random.choice(pakistani_female_names)

# Add the custom provider to Faker
f.add_provider(PakistaniNameProvider)

# Define a custom provider for Pakistani addresses
class PakistaniAddressProvider:
    def __init__(self, faker):
        self.faker = faker

    def pakistani_address(self):
        return random.choice(addresses)

# Add the custom provider to Faker
f.add_provider(PakistaniAddressProvider)

# List of Pakistani male and female names
pakistani_male_names = [
    "Muhammad", "Ali", "Ahmed", "Hassan", "Usman", "Amir", "Fahad", "Bilal", "Imran", "Omar",
    "Farhan", "Saad", "Zain", "Arslan", "Ayan", "Haris", "Hamza", "Danish", "Shahzaib", "Azlan",
    "Saeed", "Samiullah", "Junaid", "Tariq", "Talha", "Waqas", "Waleed", "Kashif", "Asad", "Yasir",
    "Naveed", "Salman", "Fahim", "Ahsan", "Bilawal", "Faisal", "Atif", "Waheed", "Faizan", "Kamran",
    "Waqar", "Rehan", "Noman", "Imtiaz", "Umair", "Asim", "Arif", "Fawad", "Raheel", "Rizwan"
]

pakistani_female_names = [
    "Fatima", "Ayesha", "Zainab", "Maryam", "Amina", "Sana", "Hira", "Sarah", "Alina", "Mahnoor",
    "Hina", "Sehar", "Amna", "Laiba", "Sidra", "Zoya", "Anaya", "Saba", "Hadiqa", "Arisha",
    "Aleena", "Madiha", "Sadia", "Arooj", "Kinza", "Rida", "Aiza", "Asma", "Arooba", "Sonia",
    "Laraib", "Samina", "Nimra", "Hafsa", "Sania", "Hoorain", "Warda", "Alisha", "Sumbul",
    "Gul-e-Rana", "Rubab", "Mariam", "Farah", "Parveen", "Nasreen", "Nazia", "Rabia", "Fiza",
    "Kiran", "Aqsa"
]

# List of Pakistani last names
pakistani_last_names = [
    "Khan", "Ahmed", "Malik", "Hussain", "Butt", "Sheikh", "Javed", "Iqbal", "Siddiqui", "Farooq",
    "Mirza", "Rana", "Khalid", "Chaudhry", "Nawaz", "Bhatti", "Ali", "Shah", "Raza", "Akhtar",
    "Awan", "Qureshi", "Gill", "Hassan", "Aslam", "Anwar", "Dar", "Zafar", "Shafi", "Shahbaz",
    "Tariq", "Nadeem", "Saleem", "Aziz", "Rizvi", "Hashmi", "Bukhari", "Jamil", "Sadiq", "Zaman",
    "Usman", "Iqbal", "Waheed", "Sultan", "Mehmood", "Waseem", "Rehman", "Kazmi", "Naseer"
]

addresses = [
    "Street 10, Block H, Johar Town", "Street 5, Block C, Johar Town", "Street 15-A, Block F, Johar Town",
    "Street 9, Sub-Town C, Johar Town", "Street 3-A, Mahla 2, Johar Town", "Street 12, Block E, Johar Town",
    "Street 8, Mahla 3, Johar Town", "Street 4, Block G, Johar Town", "Street 2, Block B, Johar Town",
    "Street 12, Sub-Town A, Johar Town", "Street 6, Block A, Johar Town", "Street 7, Sub-Town B, Johar Town",
    "Street 11, Block D, Johar Town", "Street 1, Block C, Johar Town", "Street 14, Mahla 1, Johar Town",
    "Street 8, Block F, Johar Town", "Street 3, Mahla 4, Johar Town", "Street 5, Block E, Johar Town"
]

# Function to generate unique CNIC
def generate_unique_cnic(existing_cnic):
    while True:
        cnic = f"35202-{f.random_number(digits=7, fix_len=True)}-{f.random_int(1, 9)}"
        if cnic not in existing_cnic:
            existing_cnic.add(cnic)
            return cnic

# Function to generate voter data
def generate_voter_data(num_voters):
    voters = []
    existing_cnic = set()
    male_count = int(num_voters * 0.6)
    female_count = num_voters - male_count

    for _ in range(male_count):
        first_name = f.pakistani_male_name()
        last_name = random.choice(pakistani_last_names)
        gender = "male"
        marital_status = random.choice(["Single", "Married"])
        dob = f.date_of_birth(minimum_age=18, maximum_age=80).strftime("%Y-%m-%d")
        address = f.pakistani_address()
        cnic = generate_unique_cnic(existing_cnic)
        disability = "No" if random.random() < 0.90 else "Yes"

        voter = {
            "First Name": first_name,
            "Last Name": last_name,
            "Gender": gender,
            "Marital Status": marital_status,
            "Date of Birth": dob,
            "Address": address,
            "CNIC": cnic,
            "Disability": disability
        }
        voters.append(voter)

    for _ in range(female_count):
        first_name = f.pakistani_female_name()
        last_name = random.choice(pakistani_last_names)
        gender = "female"
        marital_status = random.choice(["Single", "Married"])
        dob = f.date_of_birth(minimum_age=18, maximum_age=80).strftime("%Y-%m-%d")
        address = f.pakistani_address()
        cnic = generate_unique_cnic(existing_cnic)
        disability = "No" if random.random() < 0.90 else "Yes"

        voter = {
            "First Name": first_name,
            "Last Name": last_name,
            "Gender": gender,
            "Marital Status": marital_status,
            "Date of Birth": dob,
            "Address": address,
            "CNIC": cnic,
            "Disability": disability
        }
        voters.append(voter)

    # Shuffle the list to mix male and female voters randomly
    random.shuffle(voters)
    return voters

# Generate voter data
voter_data = generate_voter_data(1087)

# Database connection
Driver_Name = 'SQL SERVER'
Server_Name = 'DESKTOP-TF6SVF4'
Database_Name = 'votingSystem_fa22_bcs_047'

# ODBC connection string
connection_String = (
    f"Driver={{{Driver_Name}}};"
    f"Server={Server_Name};"
    f"Database={Database_Name};"
    f"Trusted_Connection=yes;"
)

# Connect to the database
conn = odbc.connect(connection_String)
print(conn)
cursor = conn.cursor()

# Create Voter table if it doesn't exist
cursor.execute('''
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Voter' AND xtype='U')
    CREATE TABLE Voter (
        FirstName NVARCHAR(50),
        LastName NVARCHAR(50),
        Gender NVARCHAR(10),
        MaritalStatus NVARCHAR(10),
        DateOfBirth DATE,
        Address NVARCHAR(200),
        CNIC NVARCHAR(15),
        Disability NVARCHAR(3),
        CONSTRAINT PK_Voter_ID PRIMARY KEY (CNIC)
    )
''')
conn.commit()

# Insert voter data into the Voter table
for voter in voter_data:
    cursor.execute('''
        INSERT INTO Voter (FirstName, LastName, Gender, MaritalStatus, DateOfBirth, Address, CNIC, Disability)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', voter["First Name"], voter["Last Name"], voter["Gender"], voter["Marital Status"],
    voter["Date of Birth"], voter["Address"], voter["CNIC"], voter["Disability"])

conn.commit()
cursor.close()
conn.close()

print("Data inserted successfully.")
