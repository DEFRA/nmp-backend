CREATE TABLE [dbo].[ManureTypeLinkToApplicationMethods]
(
	ManureTypeID INT,
    ApplicationMethodID INT,
    PRIMARY KEY (ManureTypeID, ApplicationMethodID),
    FOREIGN KEY (ManureTypeID) REFERENCES ManureTypes(ID),
    FOREIGN KEY (ApplicationMethodID) REFERENCES ApplicationMethods(ID)
)
