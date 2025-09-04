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

# Function to generate unique officer ID
def generate_unique_officer_id(existing_ids):
    while True:
        officer_id = f.random_number(digits=3)
        if officer_id not in existing_ids:
            return officer_id

# Function to generate presiding officer data
def generate_presiding_officer_data(num_officers, dept_ids, existing_ids):
    officers = []
    for _ in range(num_officers):
        first_name = f.pakistani_male_name()
        last_name = random.choice(pakistani_last_names)
        gender = "male"
        if random.random() < 0.5:  # 50% chance to generate female officer
            first_name = f.pakistani_female_name()
            gender = "female"
        officer_id = generate_unique_officer_id(existing_ids)
        existing_ids.add(officer_id)  # Add the new ID to the set of existing IDs
        scale = random.randint(18, 21)
        dept_id = random.choice(dept_ids)

        officer = {
            "First Name": first_name,
            "Last Name": last_name,
            "ID": officer_id,
            "Gender": gender,
            "Scale": scale,
            "DeptID": dept_id
        }
        officers.append(officer)
    return officers

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
cursor = conn.cursor()

# Fetch Department IDs from the Department table
cursor.execute('SELECT DepartmentID FROM Department')
department_ids = [row.DepartmentID for row in cursor.fetchall()]

# Fetch existing presiding officer IDs to avoid duplicates
cursor.execute('SELECT ID FROM PresidingOfficer')
existing_ids = {row.ID for row in cursor.fetchall()}

# Generate presiding officer data
presiding_officer_data = generate_presiding_officer_data(50, department_ids, existing_ids)

# Insert presiding officer data into the PresidingOfficer table
for officer in presiding_officer_data:
    cursor.execute('''
        INSERT INTO PresidingOfficer (FirstName, LastName, ID, Gender, Scale, DeptID)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', officer["First Name"], officer["Last Name"], officer["ID"], officer["Gender"],
    officer["Scale"], officer["DeptID"])

conn.commit()
cursor.close()
conn.close()

print("Data inserted successfully.")
