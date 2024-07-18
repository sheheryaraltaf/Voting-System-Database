import pyodbc
import random
from datetime import datetime, timedelta

# Database connection parameters
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
cursor = conn.cursor()

# Function to retrieve 1000 entries from VoteRecord table
def retrieve_vote_records():
    cursor.execute("SELECT TOP 1000 VoterCNIC, CandidateSymbol FROM VoteRecord")
    vote_records = cursor.fetchall()
    return vote_records

# Function to assign random booth numbers
def assign_booth_numbers(num_votes):
    booth_numbers = [random.randint(1, 6) for _ in range(num_votes)]
    return booth_numbers

# Function to generate cast times
def generate_cast_times(start_time, end_time, num_votes, booth_ids):
    # Calculate time difference
    time_diff = end_time - start_time
    # Calculate time interval per vote
    time_interval = time_diff / num_votes
    # Initialize list to store cast times
    cast_times = []
    # Generate cast times with adjusted logic
    for i in range(num_votes):
        # Add a random offset to the time interval
        random_offset = random.randint(240, 600)  # Random offset between 4 to 10 minutes in seconds
        # Calculate next time
        next_time = start_time + (i * time_interval) + timedelta(seconds=random_offset)
        # Append next time to cast times list along with booth ID
        cast_times.append((next_time, booth_ids[i]))
    return cast_times

# Retrieve 1000 entries from VoteRecord table
vote_records = retrieve_vote_records()

# Assign random booth numbers
booth_numbers = assign_booth_numbers(len(vote_records))

# Adjust the time range for generating cast times
start_time = datetime.strptime('2023-02-21 08:00:00', '%Y-%m-%d %H:%M:%S')
end_time = datetime.strptime('2023-02-21 16:00:00', '%Y-%m-%d %H:%M:%S')

# Generate cast times with adjusted logic
cast_times = generate_cast_times(start_time, end_time, len(vote_records), booth_numbers)

# Sort the cast_times list based on the cast time
cast_times.sort()

# Insert data into VoteResult table
for i in range(len(vote_records)):
    voter_cnic, candidate_symbol = vote_records[i]
    booth_id = booth_numbers[i]
    cast_time, booth_id = cast_times[i]
    cursor.execute("INSERT INTO VoteResult (VoterCNIC, CandidateSymbol, BoothID, CastTime) VALUES (?, ?, ?, ?)",
                   voter_cnic, candidate_symbol, booth_id, cast_time)

# Commit the transaction and close the connection
conn.commit()
conn.close()

print("VoteResult table populated successfully.")
