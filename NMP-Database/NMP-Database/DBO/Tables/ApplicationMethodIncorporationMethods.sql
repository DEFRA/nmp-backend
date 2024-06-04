CREATE TABLE [dbo].[ApplicationMethodIncorporationMethods]
(	
   ApplicationMethodID INT NOT NULL,
   IncorporationMethodID INT NOT NULL,
   CONSTRAINT [PK_ApplicationMethodIncorporationMethods]  PRIMARY KEY (ApplicationMethodID,IncorporationMethodID ASC),
   CONSTRAINT [FK_ApplicationMethodIncorporationMethods_ApplicationMethods_ApplicationMethodID] FOREIGN KEY (ApplicationMethodID) REFERENCES ApplicationMethods(ID),
   CONSTRAINT [FK_ApplicationMethodIncorporationMethods_IncorporationMethods_IncorporationMethodID] FOREIGN KEY (IncorporationMethodID) REFERENCES IncorporationMethods(ID)
)
