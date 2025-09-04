import pyodbc
import random

# Function to connect to the database
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
    return pyodbc.connect(connection_String)

# Function to insert vote records into the database
def insert_vote_records():
    conn = connect_to_database()
    cursor = conn.cursor()

    # Retrieve all CNICs from the voter table
    cursor.execute("SELECT CNIC FROM voter")
    voter_cnics = cursor.fetchall()

    # Retrieve all symbols from the candidate table
    cursor.execute("SELECT Symbol FROM candidates")
    candidate_symbols = cursor.fetchall()

    # Generate 1000 random votes
    votes = []
    while len(votes) < 1000:
        voter_cnic = random.choice(voter_cnics)[0]
        candidate_symbol = random.choice(candidate_symbols)[0]

        # Check if the voter has already voted
        cursor.execute("SELECT COUNT(*) FROM VoteRecord WHERE VoterCNIC = ?", (voter_cnic,))
        existing_votes_count = cursor.fetchone()[0]

        if existing_votes_count == 0:
            # Insert the vote into the VoteRecord table
            insert_query = "INSERT INTO VoteRecord (VoterCNIC, CandidateSymbol) VALUES (?, ?)"
            cursor.execute(insert_query, (voter_cnic, candidate_symbol))
            votes.append((voter_cnic, candidate_symbol))

    conn.commit()
    conn.close()

# Call the function to insert vote records
insert_vote_records()
