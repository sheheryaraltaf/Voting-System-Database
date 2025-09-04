import pyodbc
import random


def connect_to_database():
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
    conn = pyodbc.connect(connection_String)
    return conn.cursor()


def insert_polling_agents():
    cursor = connect_to_database()

    # Query to get candidate CNICs
    cursor.execute("SELECT CNIC FROM candidates")
    candidate_cnics = [row.CNIC for row in cursor.fetchall()]

    # Query to get voter data for polling agents
    cursor.execute("SELECT FirstName, LastName, Gender, CNIC FROM voter")

    # Dictionary to store the number of polling agents for each candidate
    candidate_polling_agents = {cnic: 0 for cnic in candidate_cnics}

    # List to store generated polling agent data
    polling_agent_data = []

    for row in cursor.fetchall():
        first_name, last_name, gender, cnic = row.FirstName, row.LastName, row.Gender, row.CNIC

        # Generate a unique contact number for the polling agent
        contact_number = generate_unique_contact_number(cursor)

        # Select a random candidate CNIC for the polling agent
        candidate_id = random.choice(candidate_cnics)

        # Check if the candidate has fewer than 5 polling agents
        if candidate_polling_agents[candidate_id] < 5:
            # Increment the count of polling agents for the candidate
            candidate_polling_agents[candidate_id] += 1
            # Append polling agent data to the list
            polling_agent_data.append((first_name, last_name, gender, cnic, contact_number, candidate_id))

    # Insert polling agent data into the database
    insert_query = """
        INSERT INTO PollingAgent 
        (FirstName, LastName, Gender, CNIC, ContactNumber, Candidate_ID) 
        VALUES (?, ?, ?, ?, ?, ?)
    """

    cursor.executemany(insert_query, polling_agent_data)
    cursor.commit()
    cursor.close()


def generate_unique_contact_number(cursor):
    # Generate a unique contact number not present in the candidate table
    while True:
        contact_number = f"+92{random.randint(3000000000, 3499999999)}"
        cursor.execute("SELECT COUNT(*) FROM candidates WHERE ContactNumber = ?", contact_number)
        if cursor.fetchone()[0] == 0:
            return contact_number


insert_polling_agents()
