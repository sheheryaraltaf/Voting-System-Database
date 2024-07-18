import pyodbc as odbc

# Function to establish a connection to the database
def connect_to_database():
    Driver_Name = 'SQL SERVER'
    Server_Name = 'DESKTOP-TF6SVF4'
    Database_Name = 'votingSystem_fa22_bcs_047'  # Adjust the database name as per your setup

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
    return conn, cursor

# Function to insert polling booth details into the database
def insert_polling_booth(cursor, booth_id, polling_station_id):
    cursor.execute("INSERT INTO PollingBooth (BoothID, PollingStationID) VALUES (?, ?)", (booth_id, polling_station_id))

# Function to generate and insert station booths
def generate_and_insert_station_booths(booth_count, polling_station_ids):
    conn, cursor = connect_to_database()

    # Specific assignments: Ensure certain PollingStationIDs have specific booth counts
    specific_assignments = {2: 1, 3: 1, 6: 1, 11: 1, 25: 2}
    booths_assigned = {ps_id: 0 for ps_id in polling_station_ids}

    # Assign specific counts first
    booth_index = 1
    for ps_id, count in specific_assignments.items():
        for _ in range(count):
            insert_polling_booth(cursor, booth_index, ps_id)
            booths_assigned[ps_id] += 1
            booth_index += 1

    # Commit the transaction
    conn.commit()
    cursor.close()
    conn.close()

# Manually provided PollingStationIDs
polling_station_ids = [2, 3, 6, 11, 25]

# Generate and insert exactly 6 polling booths
generate_and_insert_station_booths(booth_count=6, polling_station_ids=polling_station_ids)

print("Polling booth data inserted successfully.")
