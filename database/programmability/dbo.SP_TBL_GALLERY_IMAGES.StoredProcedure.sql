USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_TBL_GALLERY_IMAGES]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TBL_GALLERY_IMAGES]
	@action [nvarchar](4000) = NULL,
	@search [nvarchar](4000) = NULL,
	@recordcount [int] = NULL OUTPUT,
	@esit [bit] = NULL OUTPUT,
	@message [nvarchar](4000) = NULL OUTPUT,
	@id [uniqueidentifier] = NULL,
	@fk_gallery [uniqueidentifier] = NULL,
	@name [varchar](100) = NULL,
	@order [int] = NULL,
	@titolo [varchar](300) = NULL,
	@sottotitolo [varchar](1000) = NULL,
	@start [varchar](10) = NULL,
	@stop [varchar](10) = NULL,
	@link [varchar](4000) = NULL,
	@binary [image] = NULL,
	@author [varchar](4000) = NULL,
	@comment [varchar](4000) = NULL,
	@email [nvarchar](320) = NULL,
	@uploaddate [datetime] = NULL,
	@visible [bit] = NULL,
	@deleted [bit] = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF (@action='insert')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_GALLERY_IMAGES] WHERE ([id]=@id))
			BEGIN
				UPDATE [TBL_GALLERY_IMAGES] SET [id]=@id,[fk_gallery]=@fk_gallery,[name]=@name,[order]=@order,[titolo]=@titolo,[sottotitolo]=@sottotitolo,[start]=@start,[stop]=@stop,[link]=@link,[binary]=@binary,[author]=@author,[comment]=@comment,[email]=@email,[uploaddate]=@uploaddate,[visible]=@visible,[deleted]=@deleted WHERE ([id]=@id)
			END
		ELSE
			BEGIN
				INSERT INTO [TBL_GALLERY_IMAGES]([id],[fk_gallery],[name],[order],[titolo],[sottotitolo],[start],[stop],[link],[binary],[author],[comment],[email],[uploaddate],[visible],[deleted]) VALUES (@id,@fk_gallery,@name,@order,@titolo,@sottotitolo,@start,@stop,@link,@binary,@author,@comment,@email,@uploaddate,@visible,@deleted)
			END
	END
IF (@action='update_notnull')
	BEGIN
		IF EXISTS(Select [id] FROM [TBL_GALLERY_IMAGES] WHERE ([id]=@id))
			BEGIN
				UPDATE [TBL_GALLERY_IMAGES] SET [id]=ISNULL(@id,[id]),[fk_gallery]=ISNULL(@fk_gallery,[fk_gallery]),[name]=ISNULL(@name,[name]),[order]=ISNULL(@order,[order]),[titolo]=ISNULL(@titolo,[titolo]),[sottotitolo]=ISNULL(@sottotitolo,[sottotitolo]),[start]=ISNULL(@start,[start]),[stop]=ISNULL(@stop,[stop]),[link]=ISNULL(@link,[link]),[binary]=ISNULL(@binary,[binary]),[author]=ISNULL(@author,[author]),[comment]=ISNULL(@comment,[comment]),[email]=ISNULL(@email,[email]),[uploaddate]=ISNULL(@uploaddate,[uploaddate]),[visible]=ISNULL(@visible,[visible]),[deleted]=ISNULL(@deleted,[deleted]) WHERE ([id]=@id)
			END
		ELSE
			BEGIN
				INSERT INTO [TBL_GALLERY_IMAGES]([id],[fk_gallery],[name],[order],[titolo],[sottotitolo],[start],[stop],[link],[binary],[author],[comment],[email],[uploaddate],[visible],[deleted]) VALUES (@id,@fk_gallery,@name,@order,@titolo,@sottotitolo,@start,@stop,@link,@binary,@author,@comment,@email,@uploaddate,@visible,@deleted)
			END
	END
END
GO
