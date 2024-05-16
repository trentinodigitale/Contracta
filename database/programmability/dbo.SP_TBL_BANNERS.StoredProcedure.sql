USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_TBL_BANNERS]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TBL_BANNERS] 
	-- Add the parameters for the stored procedure here
	@action [nvarchar](4000) = NULL,
	@search [nvarchar](4000) = NULL,
	@recordcount [int] = NULL OUTPUT,
	@esit [bit] = NULL OUTPUT,
	@message [nvarchar](4000) = NULL OUTPUT,
	@counter [numeric](18, 12) = NULL,
	@id [uniqueidentifier] = NULL,
	@name [varchar](100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF (@action='insert')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_BANNERS] WHERE ([id]=@id))
			BEGIN
				IF NOT (EXISTS(Select [id] FROM [TBL_BANNERS] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						UPDATE [TBL_BANNERS] SET [id]=@id,[name]=@name WHERE ([id]=@id)
					END
				ELSE
					BEGIN
						SET @esit=0
						SET @message='Index Violation'
						Return 0
					END
			END
		ELSE
			BEGIN
				IF NOT (EXISTS(Select [id] FROM [TBL_BANNERS] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						INSERT INTO [TBL_BANNERS]([id],[name]) VALUES (@id,@name)
					END
			END
	END
IF (@action='update_notnull')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_BANNERS] WHERE ([id]=@id))
			BEGIN
				IF NOT (EXISTS(Select [id] FROM [TBL_BANNERS] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						UPDATE [TBL_BANNERS] SET [id]=ISNULL(@id,[id]),[name]=ISNULL(@name,[name]) WHERE ([id]=@id)
					END
			END
		ELSE
			BEGIN
				IF NOT (EXISTS(Select [id] FROM [TBL_BANNERS] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						INSERT INTO [TBL_BANNERS]([id],[name]) VALUES (@id,@name)
					END
			END
	END
END
	
GO
