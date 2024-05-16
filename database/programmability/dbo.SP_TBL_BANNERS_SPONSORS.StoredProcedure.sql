USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_TBL_BANNERS_SPONSORS]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TBL_BANNERS_SPONSORS]
	-- Add the parameters for the stored procedure here
	@action [nvarchar](4000) = NULL,
	@search [nvarchar](4000) = NULL,
	@recordcount [int] = NULL OUTPUT,
	@esit [bit] = NULL OUTPUT,
	@message [nvarchar](4000) = NULL OUTPUT,
	@id [uniqueidentifier] = NULL,
	@fk_lines [uniqueidentifier] = NULL,
	@order [int] = NULL,
	@titolo [varchar](300) = NULL,
	@sottotitolo [varchar](1000) = NULL,
	@start [varchar](10) = NULL,
	@stop [varchar](10) = NULL,
	@link [varchar](4000) = NULL,
	@binary [image] = NULL,
	@width [int] = NULL,
	@height [int] = NULL,
	@colspan [int] = NULL,
	@empty [bit] = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
IF (@action='insert')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_BANNERS_SPONSORS] WHERE ([id]=@id))
			BEGIN
				UPDATE [TBL_BANNERS_SPONSORS] SET [id]=@id,[fk_lines]=@fk_lines,[order]=@order,[titolo]=@titolo,[sottotitolo]=@sottotitolo,[start]=@start,[stop]=@stop,[link]=@link,[binary]=@binary,[width]=@width,[height]=@height,[colspan]=@colspan,[empty]=@empty WHERE ([id]=@id)
			END
		ELSE
			BEGIN
				INSERT INTO [TBL_BANNERS_SPONSORS]([id],[fk_lines],[order],[titolo],[sottotitolo],[start],[stop],[link],[binary],[width],[height],[colspan],[empty]) VALUES (@id,@fk_lines,@order,@titolo,@sottotitolo,@start,@stop,@link,@binary,@width,@height,@colspan,@empty)
			END
	END
IF (@action='update_notnull')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_BANNERS_SPONSORS] WHERE ([id]=@id))
			BEGIN
				UPDATE [TBL_BANNERS_SPONSORS] SET [id]=ISNULL(@id,[id]),[fk_lines]=ISNULL(@fk_lines,[fk_lines]),[order]=ISNULL(@order,[order]),[titolo]=ISNULL(@titolo,[titolo]),[sottotitolo]=ISNULL(@sottotitolo,[sottotitolo]),[start]=ISNULL(@start,[start]),[stop]=ISNULL(@stop,[stop]),[link]=ISNULL(@link,[link]),[binary]=ISNULL(@binary,[binary]),[width]=ISNULL(@width,[width]),[height]=ISNULL(@height,[height]),[colspan]=ISNULL(@colspan,[colspan]),[empty]=ISNULL(@empty,[empty]) WHERE ([id]=@id)
			END
		ELSE
			BEGIN
				INSERT INTO [TBL_BANNERS_SPONSORS]([id],[fk_lines],[order],[titolo],[sottotitolo],[start],[stop],[link],[binary],[width],[height],[colspan],[empty]) VALUES (@id,@fk_lines,@order,@titolo,@sottotitolo,@start,@stop,@link,@binary,@width,@height,@colspan,@empty)
			END
	END
END
GO
