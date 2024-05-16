USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_RETTIFICA_GARA_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VIEW_TED_RETTIFICA_GARA_XML] AS
	select a.idHeader, --chiave di ingresso
			isnull(a.NEW_VALUE_DATE,'') as NEW_VALUE_DATE,
			isnull(a.NEW_VALUE_TEXT,'') as NEW_VALUE_TEXT,
			isnull(a.NEW_VALUE_TIME,'') as NEW_VALUE_TIME,
			isnull(a.OLD_VALUE_DATE,'') as OLD_VALUE_DATE,
			isnull(a.OLD_VALUE_TEXT,'') as OLD_VALUE_TEXT,
			isnull(a.OLD_VALUE_TIME,'') as OLD_VALUE_TIME,
			isnull(a.SECTION_NUMBER,'') as SECTION_NUMBER,
			isnull(a.SECTION_TO_MODIFY,'') as SECTION_TO_MODIFY,
			isnull(a.NEW_MAIN_CPV_SEC,'') as NEW_MAIN_CPV_SEC,
			isnull(a.OLD_MAIN_CPV_SEC,'') as OLD_MAIN_CPV_SEC,
			isnull(a.CIG_RETTIFICA,'') as CIG_RETTIFICA
		from Document_TED_RETTIFICA a with(nolock)

GO
