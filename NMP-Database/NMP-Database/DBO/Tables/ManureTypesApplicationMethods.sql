CREATE TABLE [dbo].[ManureTypesApplicationMethods]
(
	ManureTypeID INT NOT NULL,
    ApplicationMethodID INT NOT NULL,
    CONSTRAINT [PK_ManureTypesApplicationMethods]  PRIMARY KEY (ManureTypeID, ApplicationMethodID ASC),
    CONSTRAINT [FK_ManureTypesApplicationMethods_ManureTypes_ManureTypeID]   FOREIGN KEY (ManureTypeID) REFERENCES ManureTypes(ID),
    CONSTRAINT [FK_ManureTypesApplicationMethods_ApplicationMethods_ApplicationMethodID]   FOREIGN KEY (ApplicationMethodID) REFERENCES ApplicationMethods(ID)
)
