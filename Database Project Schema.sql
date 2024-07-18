create database votingSystem_fa22_bcs_047
use votingSystem_fa22_bcs_047

CREATE TABLE constituency (
    ConstituencyID INT ,
    Population INT,
    Area NVARCHAR(100),
    RegisteredVotes INT NOT NULL,
    PollingStations INT NOT NULL,
	CONSTRAINT PK_Constituency_ID PRIMARY KEY (ConstituencyID)
);

CREATE NONCLUSTERED INDEX IX_Constituency_Area ON constituency (Area);

CREATE TABLE voter(
 
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10)NOT NULL,
    MaritalStatus NVARCHAR(10),
    DateOfBirth DATE NOT NULL,
    Address NVARCHAR(200),
    CNIC NVARCHAR(15),
    Disability NVARCHAR(3),
    CONSTRAINT PK_Voter_ID PRIMARY KEY (CNIC)
);

CREATE NONCLUSTERED INDEX IX_Candidates_FirstName ON candidates (FirstName);
CREATE NONCLUSTERED INDEX IX_Candidates_LastName ON candidates (LastName);

CREATE TABLE candidates (
        CNIC NVARCHAR (15) NOT NULL,
        FirstName NVARCHAR(50) NOT NULL,
        LastName NVARCHAR(50) NOT NULL,
        Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('male', 'female')),
        ContactNumber NVARCHAR(15) Unique,
        DateOfBirth DATE NOT NULL,
        Symbol NVARCHAR(50) NOT NULL,
        CONSTRAINT PK_Candidates_ID PRIMARY KEY (CNIC)    
    );
	ALTER TABLE candidates
    ADD CONSTRAINT UQ_CandidateSymbol UNIQUE (Symbol);

Create table PollingAgent(
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10)NOT NULL,
	CNIC NVARCHAR (15) NOT NULL,
	ContactNumber NVARCHAR(15) Unique,
	Candidate_ID NVARCHAR(15) NOT NULL,
	CONSTRAINT PK_PollingAgent_ID PRIMARY KEY (CNIC) ,
	FOREIGN KEY (Candidate_ID) references candidates(CNIC)
	);

CREATE TABLE VoteRecord (
    VoterCNIC NVARCHAR(15),
    CandidateSymbol NVARCHAR(50),
    CONSTRAINT PK_VoteRecord PRIMARY KEY (VoterCNIC, CandidateSymbol),
    FOREIGN KEY (VoterCNIC) REFERENCES voter(CNIC),
    FOREIGN KEY (CandidateSymbol) REFERENCES candidates(Symbol)
);
select * from VoteRecord

CREATE TABLE department (
    DepartmentID INT,
    DepartmentName NVARCHAR(100)
	CONSTRAINT PK_Department_ID PRIMARY KEY ( DepartmentID),
);

CREATE NONCLUSTERED INDEX IX_Department_DepartmentName ON department (DepartmentName);


CREATE TABLE PresidingOfficer (
    ID INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female')),
    Scale INT,
    DeptID INT,
    CONSTRAINT FK_PresidingOfficer_Dept FOREIGN KEY (DeptID) REFERENCES Department(DepartmentID)
);
select * from Officer

CREATE TABLE PollingStation (
    PollingStationID INT,
    Address NVARCHAR(255),
    VoterSize INT,
    NumBooths INT,
    EmployeeSize INT,
    PresidingOfficerID INT,
    Sensitivity NVARCHAR(50),
    ConstituencyID INT,
    PolicePersonnel INT,
    CONSTRAINT PK_PollingStation_ID PRIMARY KEY (PollingStationID),
	CONSTRAINT FK_PresidingOfficerID_Dept FOREIGN KEY (PresidingOfficerID) REFERENCES PresidingOfficer(ID)
);
select * from PollingStation

CREATE TABLE PollingBooth (
    BoothID INT ,
    PollingStationID INT,
    CONSTRAINT PK_Booth_ID PRIMARY KEY (BoothID),
    CONSTRAINT FK_PollingBooth_PollingStation FOREIGN KEY (PollingStationID) REFERENCES PollingStation(PollingStationID)
);

CREATE TABLE Officer (
    OfficerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    CNIC NVARCHAR(13) UNIQUE,
    ContactNo NVARCHAR(13),
    Position NVARCHAR(50),
    Scale INT,
    DepartmentID INT,
	BoothID INT,
    CONSTRAINT FK_Officer_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID), 
	CONSTRAINT FK_Booth_ID FOREIGN KEY (BoothID) REFERENCES PollingBooth(BoothID),
);

CREATE TABLE VoteResult (		
    VoteID INT PRIMARY KEY IDENTITY(1,1),
    VoterCNIC NVARCHAR(15),
    CandidateSymbol NVARCHAR(50),
    BoothID INT,
    CastTime DATETIME,
    CONSTRAINT FK_VoteResult_VoteRecord FOREIGN KEY (VoterCNIC, CandidateSymbol) REFERENCES VoteRecord(VoterCNIC, CandidateSymbol),
    CONSTRAINT FK_VoteResult_Booth FOREIGN KEY (BoothID) REFERENCES PollingBooth(BoothID)
);
select * from VoteResult














-- Creating non-clustered indexes for the Candidate table
CREATE NONCLUSTERED INDEX IX_Candidates_FirstName ON candidates (FirstName);
CREATE NONCLUSTERED INDEX IX_Candidates_LastName ON candidates (LastName);

-- Creating non-clustered indexes for the Department table
CREATE NONCLUSTERED INDEX IX_Department_DepartmentName ON department (DepartmentName);

-- Creating non-clustered indexes for the Constituency table
CREATE NONCLUSTERED INDEX IX_Constituency_Area ON constituency (Area);


-- Reports

SELECT 
    c.ConstituencyID,
    c.Area,
    ps.PollingStationID,
    ps.Address,
    COUNT(vr.VoterCNIC) AS VotesCast,
    c.RegisteredVotes,
    (COUNT(vr.VoterCNIC) * 100.0 / c.RegisteredVotes) AS TurnoutPercentage
FROM 
    Constituency c
JOIN 
    PollingStation ps ON c.ConstituencyID = ps.ConstituencyID
LEFT JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    c.ConstituencyID, c.Area, ps.PollingStationID, ps.Address, c.RegisteredVotes;



SELECT 
    c.CNIC,
    c.FirstName,
    c.LastName,
    cs.ConstituencyID,
    cs.Area,
    COUNT(vr.VoterCNIC) AS VotesReceived,
    RANK() OVER (PARTITION BY cs.ConstituencyID ORDER BY COUNT(vr.VoterCNIC) DESC) AS RankInConstituency
FROM 
    Candidates c
LEFT JOIN 
    VoteResult vr ON c.Symbol = vr.CandidateSymbol
LEFT JOIN 
    PollingBooth pb ON vr.BoothID = pb.BoothID
LEFT JOIN 
    PollingStation ps ON pb.PollingStationID = ps.PollingStationID
LEFT JOIN 
    Constituency cs ON ps.ConstituencyID = cs.ConstituencyID
GROUP BY 
    c.CNIC, c.FirstName, c.LastName, cs.ConstituencyID, cs.Area;


SELECT 
    cs.ConstituencyID,
    cs.Area,
    v.Gender,
    v.MaritalStatus,
    DATEDIFF(YEAR, v.DateOfBirth, GETDATE()) AS Age,
    COUNT(v.CNIC) AS VoterCount
FROM 
    Voter v
JOIN 
    VoteResult vr ON v.CNIC = vr.VoterCNIC
JOIN 
    PollingBooth pb ON vr.BoothID = pb.BoothID
JOIN 
    PollingStation ps ON pb.PollingStationID = ps.PollingStationID
JOIN 
    Constituency cs ON ps.ConstituencyID = cs.ConstituencyID
GROUP BY 
    cs.ConstituencyID, cs.Area, v.Gender, v.MaritalStatus, DATEDIFF(YEAR, v.DateOfBirth, GETDATE());


SELECT 
    DATEPART(HOUR, vr.CastTime) AS VotingHour,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    VoteResult vr
GROUP BY 
    DATEPART(HOUR, vr.CastTime)
ORDER BY 
    VotingHour;

SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address
HAVING COUNT(vr.VoteID) = (
    SELECT 
        MAX(VotesCast) 
    FROM (
        SELECT 
            pb.BoothID,
            COUNT(vr.VoteID) AS VotesCast
        FROM 
            PollingStation ps
        JOIN 
            PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
        LEFT JOIN 
            VoteResult vr ON pb.BoothID = vr.BoothID
        GROUP BY 
            pb.BoothID
    ) AS BoothVotes
);

SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address
HAVING COUNT(vr.VoteID) = (
    SELECT 
        MIN(VotesCast) 
    FROM (
        SELECT 
            pb.BoothID,
            COUNT(vr.VoteID) AS VotesCast
        FROM 
            PollingStation ps
        JOIN 
            PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
        LEFT JOIN 
            VoteResult vr ON pb.BoothID = vr.BoothID
        GROUP BY 
            pb.BoothID
    ) AS BoothVotes
);


SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    MIN(COUNT(vr.VoteID)) AS MinVotes
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address

SELECT 
    c.FirstName + ' ' + c.LastName AS CandidateName,
    c.Symbol AS CandidateSymbol,
    cs.ConstituencyID,
    COUNT(vr.VoteID) AS VotesReceived
FROM 
    Candidates c
LEFT JOIN 
    VoteResult vr ON c.Symbol = vr.CandidateSymbol
LEFT JOIN 
    PollingBooth pb ON vr.BoothID = pb.BoothID
LEFT JOIN 
    PollingStation ps ON pb.PollingStationID = ps.PollingStationID
LEFT JOIN 
    Constituency cs ON ps.ConstituencyID = cs.ConstituencyID
GROUP BY 
    c.FirstName, c.LastName, c.Symbol, cs.ConstituencyID
ORDER BY 
    COUNT(vr.VoteID) DESC;

	SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    COUNT(vr.VoteID) AS VotesCast,
    (COUNT(vr.VoteID) * 100.0) / NULLIF((
        SELECT 
            SUM(c.RegisteredVotes) 
        FROM 
            Constituency c 
        WHERE 
            c.ConstituencyID = (SELECT ConstituencyID FROM PollingStation WHERE PollingStationID = ps.PollingStationID)
    ), 0) AS TurnoutPercentage
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address;





