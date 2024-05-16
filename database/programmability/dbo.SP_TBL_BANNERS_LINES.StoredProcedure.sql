USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_TBL_BANNERS_LINES]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TBL_BANNERS_LINES] 
	-- Add the parameters for the stored procedure here
	@action [nvarchar](4000) = NULL,
	@search [nvarchar](4000) = NULL,
	@recordcount [int] = NULL OUTPUT,
	@esit [bit] = NULL OUTPUT,
	@message [nvarchar](4000) = NULL OUTPUT,
	@id [uniqueidentifier] = NULL,
	@fk_banner [uniqueidentifier] = NULL,
	@order [int] = NULL,
	@type [varchar](50) = NULL,
	@visible [bit] = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF (@action='insert')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_BANNERS_LINES] WHERE ([id]=@id))
			BEGIN
				UPDATE [TBL_BANNERS_LINES] SET [id]=@id,[fk_banner]=@fk_banner,[order]=@order,[type]=@type,[visible]=@visible WHERE ([id]=@id)
			END
		ELSE
			BEGIN
				INSERT INTO [TBL_BANNERS_LINES]([id],[fk_banner],[order],[type],[visible]) VALUES (@id,@fk_banner,@order,@type,@visible)
			END
	END
IF (@action='update_notnull')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_BANNERS_LINES] WHERE ([id]=@id))
			BEGIN
				UPDATE [TBL_BANNERS_LINES] SET [id]=ISNULL(@id,[id]),[fk_banner]=ISNULL(@fk_banner,[fk_banner]),[order]=ISNULL(@order,[order]),[type]=ISNULL(@type,[type]),[visible]=ISNULL(@visible,[visible]) WHERE ([id]=@id)
			END
		ELSE
			BEGIN
				INSERT INTO [TBL_BANNERS_LINES]([id],[fk_banner],[order],[type],[visible]) VALUES (@id,@fk_banner,@order,@type,@visible)
			END
	END
END
GO
