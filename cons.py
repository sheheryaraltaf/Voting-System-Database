import pyodbc as odbc
from faker import Faker

# Initialize Faker
fake = Faker('en_IN')

# Generate sample data
ConstituencyID = fake.random_int(1, 100)
Population = fake.random_int(2000, 2300)
Area = 'Johar Town'
RegisteredVotes = fake.random_int(1000, 1500)
PollingStations = 5


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
cursor=conn.cursor()

# Create Constituency table if it doesn't exist
cursor.execute('''
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Constituency' AND xtype='U')
    CREATE TABLE Constituency (
        ConstituencyID INT,
        Population INT,
        Area NVARCHAR(100),
        RegisteredVotes INT,
        PollingStations INT,
        CONSTRAINT PK_Constituency_ID PRIMARY KEY (ConstituencyID)
    )
''')
conn.commit()

# Insert sample data into the Constituency table
cursor.execute('''
    INSERT INTO constituency (ConstituencyID, Population, Area, RegisteredVotes, PollingStations)
    VALUES (?, ?, ?, ?, ?)
''', (ConstituencyID, Population, Area, RegisteredVotes, PollingStations))

conn.commit()

# Close the cursor and connection
cursor.close()
conn.close()

print("Data inserted successfully.")
