USE [AFLink_TND]
GO
/****** Object:  View [dbo].[STRUTTURA_APPARTENENZA_FROM_ID_ROW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[STRUTTURA_APPARTENENZA_FROM_ID_ROW] as
select 
	id as  ID_FROM , id as LinkedDoc , 'New' as JumpCheck 
		from  az_struttura with (nolock)
GO
