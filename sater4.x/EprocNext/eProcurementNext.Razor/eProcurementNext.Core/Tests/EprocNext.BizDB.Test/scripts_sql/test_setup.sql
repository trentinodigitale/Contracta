
CREATE TABLE [dbo].[_Test](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Number] [int] NULL,
	[Number2] [float] NULL,
	[Text] [nvarchar](500) NULL,
	[Text2] [varchar](20) NULL,
	[ImageBLOB] [image] NULL,
	[LastUpdate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[_Test] ADD  CONSTRAINT [DF__Test_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]

CREATE TRIGGER [TRIG_Test_LastUpdate] ON [dbo].[_Test] FOR INSERT, UPDATE
AS
IF @@ROWCOUNT=0 RETURN
UPDATE U SET [LastUpdate] = GETDATE()
FROM [dbo].[_Test] U INNER JOIN INSERTED I ON U.Id = I.Id