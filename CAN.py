from datetime import datetime, timedelta
import random
from faker import Faker
import pyodbc as odbc

# Initialize Faker
f = Faker('en_IN')

# Function to generate candidate data
def generate_candidate_data():
    candidates = []

    # Connect to the database
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

    # Retrieve unique CNICs from the voter table
    cursor.execute('SELECT TOP 5 * FROM voter ORDER BY NEWID()')
    voter_records = cursor.fetchall()

    # List of party symbols
    party_symbols = ["Crane", "Lion", "Bat", "Scooter", "Arrow"]

    for voter in voter_records:
        first_name = voter[0]
        last_name = voter[1]
        gender = voter[2]
        contact_number = f"+92{f.random_number(digits=9, fix_len=True)}"
        dob = voter[4]
        symbol = party_symbols.pop(0)  # Pick a symbol and remove it from the list

        candidate = {
            "CNIC": voter[6],
            "FirstName": first_name,
            "LastName": last_name,
            "Gender": gender,
            "ContactNumber": contact_number,
            "DateOfBirth": dob,
            "Symbol": symbol
        }
        candidates.append(candidate)

    cursor.close()
    conn.close()

    return candidates

# Function to insert candidate data into the database
def insert_candidates_to_db(candidates):
    # Connect to the database
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

    # Insert candidate data into the database
    for candidate in candidates:
        cursor.execute('''
            INSERT INTO candidates (CNIC, FirstName, LastName, Gender, ContactNumber, DateOfBirth, Symbol)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            candidate['CNIC'],
            candidate['FirstName'],
            candidate['LastName'],
            candidate['Gender'],
            candidate['ContactNumber'],
            candidate['DateOfBirth'],
            candidate['Symbol']
        ))
    conn.commit()

    cursor.close()
    conn.close()

# Generate candidate data
candidate_data = generate_candidate_data()

# Insert candidate data into the database
insert_candidates_to_db(candidate_data)

print("Candidate data inserted into the database successfully.")
