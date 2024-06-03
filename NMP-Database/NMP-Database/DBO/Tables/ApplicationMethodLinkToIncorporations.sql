CREATE TABLE [dbo].[ApplicationMethodLinkToIncorporations]
(	
    ApplicationMethodID INT,
    IncorporationID INT,
    PRIMARY KEY (IncorporationID, ApplicationMethodID),
    FOREIGN KEY (ApplicationMethodID) REFERENCES ApplicationMethods(ID),
    FOREIGN KEY (IncorporationID) REFERENCES Incorporations(ID)
)
