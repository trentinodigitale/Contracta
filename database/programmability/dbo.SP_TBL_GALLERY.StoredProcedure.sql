USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_TBL_GALLERY]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TBL_GALLERY] 
	-- Add the parameters for the stored procedure here
	@action [nvarchar](4000) = NULL,
	@id [uniqueidentifier] = NULL,
	@name [varchar](100) = NULL,
	@width [int] = NULL,
	@height [int] = NULL,
	@bgcolor [varchar](7) = NULL,
	@timed [bit] = NULL,
	@show_arrows [bit] = NULL,
	@show_infopane [bit] = NULL,
	@show_carousel [bit] = NULL,
	@show_links [bit] = NULL,
	@preload [bit] = NULL,
	@preload_images [bit] = NULL,
	@preload_errorimages [bit] = NULL,
	@delay [int] = NULL,
	@style [nvarchar](4000) = NULL,
	@transparency [int] = NULL,
	@public [bit] = NULL,
	@uploadmessage [nvarchar](4000) = NULL,
	@deleted [bit] = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF (@action='insert')
	BEGIN	
		IF EXISTS(Select [id] FROM [TBL_GALLERY] WHERE ([id]=@id))
			BEGIN
				IF NOT EXISTS(Select [id] FROM [TBL_GALLERY] WHERE (NOT ([id]=@id)) AND (([name]=@name)))
					BEGIN						
						UPDATE [TBL_GALLERY] SET [id]=@id,[name]=@name,[width]=@width,[height]=@height,[bgcolor]=@bgcolor,[timed]=@timed,[show_arrows]=@show_arrows,[show_infopane]=@show_infopane,[show_carousel]=@show_carousel,[show_links]=@show_links,[preload]=@preload,[preload_images]=@preload_images,[preload_errorimages]=@preload_errorimages,[delay]=@delay,[style]=@style,[transparency]=@transparency,[public]=@public,[uploadmessage]=@uploadmessage,[deleted]=@deleted WHERE ([id]=@id)	
					END
			END				
		ELSE
			BEGIN
				print 'non esiste'
				IF NOT (EXISTS(Select [id] FROM [TBL_GALLERY] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						INSERT INTO [TBL_GALLERY]([id],[name],[width],[height],[bgcolor],[timed],[show_arrows],[show_infopane],[show_carousel],[show_links],[preload],[preload_images],[preload_errorimages],[delay],[style],[transparency],[public],[uploadmessage],[deleted]) VALUES (@id,@name,@width,@height,@bgcolor,@timed,@show_arrows,@show_infopane,@show_carousel,@show_links,@preload,@preload_images,@preload_errorimages,@delay,@style,@transparency,@public,@uploadmessage,@deleted)						
					END
			END			
	END
IF (@action='update_notnull')
	BEGIN	
		IF EXISTS(Select [id] FROM [TBL_GALLERY] WHERE ([id]=@id))
			BEGIN
				IF NOT (EXISTS(Select [id] FROM [TBL_GALLERY] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						UPDATE [TBL_GALLERY] SET [id]=ISNULL(@id,[id]),[name]=ISNULL(@name,[name]),[width]=ISNULL(@width,[width]),[height]=ISNULL(@height,[height]),[bgcolor]=ISNULL(@bgcolor,[bgcolor]),[timed]=ISNULL(@timed,[timed]),[show_arrows]=ISNULL(@show_arrows,[show_arrows]),[show_infopane]=ISNULL(@show_infopane,[show_infopane]),[show_carousel]=ISNULL(@show_carousel,[show_carousel]),[show_links]=ISNULL(@show_links,[show_links]),[preload]=ISNULL(@preload,[preload]),[preload_images]=ISNULL(@preload_images,[preload_images]),[preload_errorimages]=ISNULL(@preload_errorimages,[preload_errorimages]),[delay]=ISNULL(@delay,[delay]),[style]=ISNULL(@style,[style]),[transparency]=ISNULL(@transparency,[transparency]),[public]=ISNULL(@public,[public]),[uploadmessage]=ISNULL(@uploadmessage,[uploadmessage]),[deleted]=ISNULL(@deleted,[deleted]) WHERE ([id]=@id)
					END
			END
		ELSE
			BEGIN
				IF NOT (EXISTS(Select [id] FROM [TBL_GALLERY] WHERE (NOT ([id]=@id)) AND (([name]=@name))))
					BEGIN
						INSERT INTO [TBL_GALLERY]([id],[name],[width],[height],[bgcolor],[timed],[show_arrows],[show_infopane],[show_carousel],[show_links],[preload],[preload_images],[preload_errorimages],[delay],[style],[transparency],[public],[uploadmessage],[deleted]) VALUES (@id,@name,@width,@height,@bgcolor,@timed,@show_arrows,@show_infopane,@show_carousel,@show_links,@preload,@preload_images,@preload_errorimages,@delay,@style,@transparency,@public,@uploadmessage,@deleted)
					END
			END	
	END
	END
GO
