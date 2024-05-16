USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PUBBLICITA_LEGALE_ALLEGATO_IOL_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PUBBLICITA_LEGALE_ALLEGATO_IOL_VIEW] AS

SELECT D.*, V.Value AS Not_Editable 
	FROM CTL_DOC_SIGN D WITH (NOLOCK)
		LEFT JOIN CTL_DOC_VALUE V WITH (NOLOCK) ON D.idHeader=V.IdHeader AND V.DSE_ID='NOT_EDITABLE' AND V.DZT_Name='Not_Editable'
GO
