import random
import pyodbc as odbc
from faker import Faker
from faker.providers import BaseProvider

# List of departments with their IDs
pakistan_departments = [
    {"name": "Education Department", "id": 101},
    {"name": "Health Department", "id": 102},
    {"name": "Agriculture Department", "id": 103},
    {"name": "Transport Department", "id": 104},
    {"name": "Public Works Department", "id": 105},
    {"name": "Urban Planning Department", "id": 106},
    {"name": "Water Resources Department", "id": 107},
    {"name": "Environmental Protection Department", "id": 108},
    {"name": "Social Welfare Department", "id": 109},
    {"name": "Labor Department", "id": 110},
    {"name": "Energy Department", "id": 111},
    {"name": "Housing Department", "id": 112},
    {"name": "Finance Department", "id": 113},
    {"name": "Commerce Department", "id": 114},
    {"name": "Information Technology Department", "id": 115},
    {"name": "Tourism Department", "id": 116},
    {"name": "Culture Department", "id": 117},
    {"name": "Women Development Department", "id": 118},
    {"name": "Local Government Department", "id": 119},
    {"name": "Rural Development Department", "id": 120},
    {"name": "Punjab Police", "id": 121}
]

# Custom provider for Pakistani departments
class PakistaniDepartmentProvider(BaseProvider):
    def department(self):
        return random.choice(pakistan_departments)

# Initialize Faker and add the custom provider
f = Faker()
f.add_provider(PakistaniDepartmentProvider)

# Function to display departments using Faker
def display_departments(faker, num_departments):
    for _ in range(num_departments):
        department = faker.department()
        print(f"Department Name: {department['name']}")
        print(f"Department ID: {department['id']}")
        print("**********")

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

# Populate department table with data
for department in pakistan_departments:
    cursor.execute('''
    INSERT INTO department (DepartmentID, DepartmentName) 
    VALUES (?, ?)
    ''', department['id'], department['name'])

# Commit the transaction and close the cursor and connection
conn.commit()
cursor.close()
conn.close()

# Call the function to display departments
if __name__ == "__main__":
    display_departments(f, len(pakistan_departments))
