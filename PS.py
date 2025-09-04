import random
import pyodbc as odbc
from faker import Faker

# Initialize Faker
fake = Faker()

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

try:
    # Connect to the database
    conn = odbc.connect(connection_String)
    cursor = conn.cursor()

    # Fetching presiding officers
    cursor.execute("SELECT ID FROM PresidingOfficer")
    presiding_officers = cursor.fetchall()

    # Check if there are presiding officers available
    if not presiding_officers:
        print("No data available in PresidingOfficer table.")
    else:
        # Convert the list of presiding officers to a list of IDs
        presiding_officer_ids = [officer.ID for officer in presiding_officers]

        # Randomly generate polling station IDs from 1 to 25
        polling_station_ids = random.sample(range(1, 26), 5)  # Example: Generating 5 polling stations for simplicity

        # Lists of addresses for polling stations
        addresses = [
            "Johar Town Hospital",
            "Girls High School Johar Town",
            "Boys Primary School Johar Town",
            "DHQ Johar Town",
            "Expo Center Johar Town"
        ]

        # ConstituencyID for all polling stations
        constituency_id = 57

        # Insert polling station data into the database
        for polling_station_id, address in zip(polling_station_ids, addresses):
            if presiding_officer_ids:
                # Randomly select a presiding officer
                presiding_officer_id = random.choice(presiding_officer_ids)
                # Remove the selected presiding officer from the list
                presiding_officer_ids.remove(presiding_officer_id)

                # Generate other attributes
                voter_size = random.randint(500, 1000)
                num_booths = random.randint(1, 2)
                employee_size = num_booths * 5
                sensitivity = random.choice(["Sensitive", "Non-Sensitive"])
                police_personnel = num_booths

                # Insert into PollingStation table
                cursor.execute('''
                    INSERT INTO PollingStation (PollingStationID, Address, VoterSize, NumBooths, EmployeeSize, PresidingOfficerID, Sensitivity, ConstituencyID, PolicePersonnel)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (polling_station_id, address, voter_size, num_booths, employee_size, presiding_officer_id, sensitivity, constituency_id, police_personnel))

                print(f"Inserted polling station {polling_station_id} with presiding officer ID {presiding_officer_id}.")
            else:
                print("Not enough presiding officers to assign to all polling stations.")
                break

        # Commit the transaction
        conn.commit()
        print("Data successfully inserted into the PollingStation table.")

except odbc.Error as e:
    print(f"Error: {e}")

finally:
    # Close the connection
    if conn:
        conn.close()
