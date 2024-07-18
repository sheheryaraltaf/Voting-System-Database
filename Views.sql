CREATE VIEW CandidateAge
AS
SELECT 
    CNIC,
    FirstName,
    LastName,
    Gender,
    DateOfBirth,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
FROM 
    dbo.candidates;

CREATE VIEW VoterGenderDistribution
AS
SELECT 
    Gender,
    COUNT(*) AS Count
FROM 
    dbo.voter
GROUP BY 
    Gender;


CREATE VIEW OfficersByDepartment
AS
SELECT 
    o.FirstName,
    o.LastName,
    o.Position,
    d.DepartmentName
FROM 
    dbo.Officer o
JOIN 
    dbo.Department d ON o.DepartmentID = d.DepartmentID;


	SELECT * FROM OfficersByDepartment;



CREATE VIEW PollingStationVotingActivity
AS
SELECT 
    ps.PollingStationID,
    ps.Address,
    COUNT(vr.VoterCNIC) AS TotalVotes
FROM 
    dbo.VoteResult vr
JOIN 
    dbo.PollingBooth pb ON vr.BoothID = pb.BoothID
JOIN 
    dbo.PollingStation ps ON pb.PollingStationID = ps.PollingStationID
GROUP BY 
    ps.PollingStationID, ps.Address;


	SELECT * FROM PollingStationVotingActivity;

CREATE VIEW DepartmentOfficerCount
WITH SCHEMABINDING
AS
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    COUNT_BIG(*) AS OfficerCount
FROM 
    dbo.Department d
JOIN 
    dbo.Officer o ON d.DepartmentID = o.DepartmentID
GROUP BY 
    d.DepartmentID, d.DepartmentName;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_DepartmentOfficerCount
ON dbo.DepartmentOfficerCount (DepartmentID, DepartmentName);

select * from  DepartmentOfficerCount


CREATE VIEW VoterParticipationByPollingStation
WITH SCHEMABINDING
AS
SELECT 
    ps.PollingStationID,
    COUNT_BIG(*) AS VoteCount
FROM 
    dbo.VoteResult vr
JOIN 
    dbo.PollingBooth pb ON vr.BoothID = pb.BoothID
JOIN 
    dbo.PollingStation ps ON pb.PollingStationID = ps.PollingStationID
GROUP BY 
    ps.PollingStationID;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_VoterParticipationByPollingStation
ON dbo.VoterParticipationByPollingStation (PollingStationID);

select * from  VoterParticipationByPollingStation