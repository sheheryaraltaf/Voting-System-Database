import pyodbc as odbc
import random

# Establishing connection
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

# Function to check if a table exists
def table_exists(table_name):
    cursor.execute("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?", table_name)
    return cursor.fetchone()[0] == 1

# Function to generate random CNIC and ensure it's unique across candidates, PollingAgent, and voter tables
def generate_unique_cnic():
    while True:
        cnic = '35' + ''.join(random.choices('0123456789', k=11))
        if all(table_exists(table) for table in ['candidates', 'PollingAgent', 'voter']):
            cursor.execute("""
                SELECT COUNT(*) 
                FROM (
                    SELECT CNIC FROM candidates 
                    UNION 
                    SELECT CNIC FROM PollingAgent 
                    UNION 
                    SELECT CNIC FROM voter
                ) AS AllCNICs 
                WHERE CNIC = ?
            """, cnic)
            count = cursor.fetchone()[0]
            if count == 0:
                return cnic
        else:
            # If any table doesn't exist, just return the generated CNIC
            return cnic

# Function to generate random contact number
def generate_contact():
    return '+92' + ''.join(random.choices('0123456789', k=10))

# Function to insert officer data
def insert_officer(first_name, last_name, gender, cnic, contact_no, position, scale, department_id, booth_id):
    cursor.execute("""
        INSERT INTO Officer (FirstName, LastName, Gender, CNIC, ContactNo, Position, Scale, DepartmentID, BoothID)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, first_name, last_name, gender, cnic, contact_no, position, scale, department_id, booth_id)
    conn.commit()

# Fetching department IDs from the Department table
cursor.execute("SELECT DepartmentID FROM Department")
department_ids = [row.DepartmentID for row in cursor.fetchall()]

# Sample datasets for first and last names
male_first_names = [
    "Muhammad", "Ali", "Ahmed", "Hassan", "Usman", "Amir", "Fahad", "Bilal", "Imran", "Omar",
    "Farhan", "Saad", "Zain", "Arslan", "Ayan", "Haris", "Hamza", "Danish", "Shahzaib", "Azlan",
    "Saeed", "Samiullah", "Junaid", "Tariq", "Talha", "Waqas", "Waleed", "Kashif", "Asad", "Yasir",
    "Naveed", "Salman", "Fahim", "Ahsan", "Bilawal", "Faisal", "Atif", "Waheed", "Faizan", "Kamran",
    "Waqar", "Rehan", "Noman", "Imtiaz", "Umair", "Asim", "Arif", "Fawad", "Raheel", "Rizwan"
]

female_first_names = [
    "Fatima", "Ayesha", "Zainab", "Maryam", "Amina", "Sana", "Hira", "Sarah", "Alina", "Mahnoor",
    "Hina", "Sehar", "Amna", "Laiba", "Sidra", "Zoya", "Anaya", "Saba", "Hadiqa", "Arisha",
    "Aleena", "Madiha", "Sadia", "Arooj", "Kinza", "Rida", "Aiza", "Asma", "Arooba", "Sonia",
    "Laraib", "Samina", "Nimra", "Hafsa", "Sania", "Hoorain", "Warda", "Alisha", "Sumbul",
    "Gul-e-Rana", "Rubab", "Mariam", "Farah", "Parveen", "Nasreen", "Nazia", "Rabia", "Fiza",
    "Kiran", "Aqsa"
]

last_names = [
    "Khan", "Ahmed", "Malik", "Hussain", "Butt", "Sheikh", "Javed", "Iqbal", "Siddiqui", "Farooq",
    "Mirza", "Rana", "Khalid", "Chaudhry", "Nawaz", "Bhatti", "Ali", "Shah", "Raza", "Akhtar",
    "Awan", "Qureshi", "Gill", "Hassan", "Aslam", "Anwar", "Dar", "Zafar", "Shafi", "Shahbaz",
    "Tariq", "Nadeem", "Saleem", "Aziz", "Rizvi", "Hashmi", "Bukhari", "Jamil", "Sadiq", "Zaman",
    "Usman", "Iqbal", "Waheed", "Sultan", "Mehmood", "Waseem", "Rehman", "Kazmi", "Naseer"
]

genders = ['Male', 'Female']
positions = ['ASSISTANT PRESIDING OFFICER', 'POLLING OFFICER', 'POLICE PERSONNEL']

# Function to assign officers to a single polling booth
def assign_officers_to_booth(booth_id):
    # Assign 2 assistant presiding officers
    for _ in range(2):
        gender = random.choice(genders)
        first_name = random.choice(male_first_names) if gender == 'Male' else random.choice(female_first_names)
        last_name = random.choice(last_names)
        cnic = generate_unique_cnic()
        contact_no = generate_contact()
        position = 'ASSISTANT PRESIDING OFFICER'
        scale = random.randint(15, 17)
        department_id = random.choice(department_ids)

        insert_officer(first_name, last_name, gender, cnic, contact_no, position, scale, department_id, booth_id)

    # Assign 1 polling officer
    gender = random.choice(genders)
    first_name = random.choice(male_first_names) if gender == 'Male' else random.choice(female_first_names)
    last_name = random.choice(last_names)
    cnic = generate_unique_cnic()
    contact_no = generate_contact()
    position = 'POLLING OFFICER'
    scale = random.randint(15, 17
    )
    department_id = random.choice(department_ids)

    insert_officer(first_name, last_name, gender, cnic, contact_no, position, scale, department_id, booth_id)

    # Assign 1 police personnel
    gender = random.choice(genders)
    first_name = random.choice(male_first_names) if gender == 'Male' else random.choice(female_first_names)
    last_name = random.choice(last_names)
    cnic = generate_unique_cnic()
    contact_no = generate_contact()
    position = 'POLICE PERSONNEL'
    scale = random.randint(15, 17)
    department_id = random.choice(department_ids)

    insert_officer(first_name, last_name, gender, cnic, contact_no, position, scale, department_id, booth_id)

# Function to assign officers to 2 polling booths
def assign_officers_to_double_booth(booth_id1, booth_id2):
    for booth_id in [booth_id1, booth_id2]:
        assign_officers_to_booth(booth_id)

# PollingBooth IDs to assign officers
polling_booth_ids = [1, 2, 3, 4, 5, 6]

# Assign officers to single booths
for booth_id in polling_booth_ids[:4]:
    assign_officers_to_booth(booth_id)

# Assign officers to double booths
assign_officers_to_double_booth(polling_booth_ids[4], polling_booth_ids[5])

# Close connection
conn.close()

print("Officers assigned successfully.")
