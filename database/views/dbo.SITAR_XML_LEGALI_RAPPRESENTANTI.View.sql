USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SITAR_XML_LEGALI_RAPPRESENTANTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SITAR_XML_LEGALI_RAPPRESENTANTI] as 

	select l.*
		from Document_OCP_LEGALI_RAPPRESENTANTI l with(nolock)
GO
