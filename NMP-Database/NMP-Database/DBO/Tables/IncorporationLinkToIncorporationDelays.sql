CREATE TABLE [dbo].[IncorporationLinkToIncorporationDelays]
(
    IncorporationID INT,
    IncorporationDelayID INT,
    PRIMARY KEY (IncorporationID, IncorporationDelayID),
    FOREIGN KEY (IncorporationID) REFERENCES Incorporations(ID),
    FOREIGN KEY (IncorporationDelayID) REFERENCES IncorporationDelays(ID)
)
