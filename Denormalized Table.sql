CREATE TABLE master (
    -- Constituency
    ConstituencyID INT,
    Population INT,
    Area NVARCHAR(100),
    RegisteredVotes INT,
    PollingStations INT,

    -- Voter
    Voter_FirstName NVARCHAR(50),
    Voter_LastName NVARCHAR(50),
    Voter_Gender NVARCHAR(10),
    Voter_MaritalStatus NVARCHAR(10),
    Voter_DateOfBirth DATE,
    Voter_Address NVARCHAR(200),
    Voter_CNIC NVARCHAR(15),
    Voter_Disability NVARCHAR(3),

    -- Candidates
    Candidate_CNIC NVARCHAR(15),
    Candidate_FirstName NVARCHAR(50),
    Candidate_LastName NVARCHAR(50),
    Candidate_Gender NVARCHAR(10),
    Candidate_ContactNumber NVARCHAR(15),
    Candidate_DateOfBirth DATE,
    Candidate_Symbol NVARCHAR(50),

    -- PollingAgent
    PollingAgent_FirstName NVARCHAR(50),
    PollingAgent_LastName NVARCHAR(50),
    PollingAgent_Gender NVARCHAR(10),
    PollingAgent_CNIC NVARCHAR(15),
    PollingAgent_ContactNumber NVARCHAR(15),
    PollingAgent_CandidateID NVARCHAR(15),

    -- VoteRecord
    VoteRecord_VoterCNIC NVARCHAR(15),
    VoteRecord_CandidateSymbol NVARCHAR(50),

    -- Department
    Department_DepartmentID INT,
    Department_DepartmentName NVARCHAR(100),

    -- PresidingOfficer
    PresidingOfficer_ID INT,
    PresidingOfficer_FirstName NVARCHAR(50),
    PresidingOfficer_LastName NVARCHAR(50),
    PresidingOfficer_Gender NVARCHAR(10),
    PresidingOfficer_Scale INT,
    PresidingOfficer_DeptID INT,

    -- PollingStation
    PollingStation_PollingStationID INT,
    PollingStation_Address NVARCHAR(255),
    PollingStation_VoterSize INT,
    PollingStation_NumBooths INT,
    PollingStation_EmployeeSize INT,
    PollingStation_Sensitivity NVARCHAR(50),
    PollingStation_ConstituencyID INT,
    PollingStation_PolicePersonnel INT,

    -- PollingBooth
    PollingBooth_BoothID INT,
    PollingBooth_PollingStationID INT,

    -- Officer
    Officer_OfficerID INT,
    Officer_FirstName NVARCHAR(100),
    Officer_LastName NVARCHAR(100),
    Officer_Gender NVARCHAR(10),
    Officer_Contact1 NVARCHAR(13),
    Officer_Position NVARCHAR(50),
    Officer_Scale INT,
    Officer_DepartmentID INT,
    Officer_BoothID INT,

    -- VoteResult
    VoteResult_VoteID INT,
    VoteResult_VoterCNIC NVARCHAR(15),
    VoteResult_CandidateSymbol NVARCHAR(50),
    VoteResult_BoothID INT,
    VoteResult_CastTime DATETIME
);

INSERT INTO master (ConstituencyID, Population, Area, RegisteredVotes, PollingStations)
SELECT ConstituencyID, Population, Area, RegisteredVotes, PollingStations FROM Constituency;

-- Insert data from Voter
INSERT INTO master (Voter_FirstName, Voter_LastName, Voter_Gender, Voter_MaritalStatus, Voter_DateOfBirth, Voter_Address, Voter_CNIC, Voter_Disability)
SELECT FirstName, LastName, Gender, MaritalStatus, DateOfBirth, Address, CNIC, Disability FROM Voter;

-- Insert data from Candidates
INSERT INTO master (Candidate_CNIC, Candidate_FirstName, Candidate_LastName, Candidate_Gender, Candidate_ContactNumber, Candidate_DateOfBirth, Candidate_Symbol)
SELECT CNIC, FirstName, LastName, Gender, ContactNumber, DateOfBirth, Symbol FROM Candidates;

-- Insert data from PollingAgent
INSERT INTO master (PollingAgent_FirstName, PollingAgent_LastName, PollingAgent_Gender, PollingAgent_CNIC, PollingAgent_ContactNumber, PollingAgent_CandidateID)
SELECT FirstName, LastName, Gender, CNIC, ContactNumber, Candidate_ID FROM PollingAgent;

-- Insert data from VoteRecord
INSERT INTO master (VoteRecord_VoterCNIC, VoteRecord_CandidateSymbol)
SELECT VoterCNIC, CandidateSymbol FROM VoteRecord;

-- Insert data from Department
INSERT INTO master (Department_DepartmentID, Department_DepartmentName)
SELECT DepartmentID, DepartmentName FROM Department;

-- Insert data from PresidingOfficer
INSERT INTO master (PresidingOfficer_ID, PresidingOfficer_FirstName, PresidingOfficer_LastName, PresidingOfficer_Gender, PresidingOfficer_Scale, PresidingOfficer_DeptID)
SELECT ID, FirstName, LastName, Gender, Scale, DeptID FROM PresidingOfficer;

-- Insert data from PollingStation
INSERT INTO master (PollingStation_PollingStationID, PollingStation_Address, PollingStation_VoterSize, PollingStation_NumBooths, PollingStation_EmployeeSize, PollingStation_Sensitivity, PollingStation_ConstituencyID, PollingStation_PolicePersonnel)
SELECT PollingStationID, Address, VoterSize, NumBooths, EmployeeSize, Sensitivity, ConstituencyID, PolicePersonnel FROM PollingStation;

-- Insert data from PollingBooth
INSERT INTO master (PollingBooth_BoothID, PollingBooth_PollingStationID)
SELECT BoothID, PollingStationID FROM PollingBooth;

-- Insert data from Officer
INSERT INTO master (Officer_OfficerID, Officer_FirstName, Officer_LastName, Officer_Gender, Officer_Contact1, Officer_Position, Officer_Scale, Officer_DepartmentID, Officer_BoothID)
SELECT OfficerID, FirstName, LastName, Gender, ContactNo, Position, Scale, DepartmentID, BoothID FROM Officer;

-- Insert data from VoteResult
INSERT INTO master (VoteResult_VoteID, VoteResult_VoterCNIC, VoteResult_CandidateSymbol, VoteResult_BoothID, VoteResult_CastTime)
SELECT VoteID, VoterCNIC, CandidateSymbol, BoothID, CastTime FROM VoteResult;

select * from master

--Voter Turnout by Age Group Report

SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 56 AND 65 THEN '56-65'
        ELSE 'Above 65'
    END AS AgeGroup,
    COUNT(*) AS VoterCount
FROM 
    master
WHERE 
    voter_DateOfBirth IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 26 AND 35 THEN '26-35'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 36 AND 45 THEN '36-45'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 46 AND 55 THEN '46-55'
        WHEN DATEDIFF(YEAR, voter_DateOfBirth, GETDATE()) BETWEEN 56 AND 65 THEN '56-65'
        ELSE 'Above 65'
    END;

-- Report to determine the voting hour during which the highest number of votes were cast.
SELECT 
    DATEPART(HOUR, vr.CastTime) AS VotingHour,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    master m
JOIN 
    VoteResult vr ON m.VoteResult_VoterCNIC = vr.VoterCNIC
GROUP BY 
    DATEPART(HOUR, vr.CastTime)



