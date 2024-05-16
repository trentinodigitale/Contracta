USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_PROVINCE_IN_CUI_OPERA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_PROVINCE_IN_CUI_OPERA] as

--PRENDE LA RADICE ITALIA O REGIONE CONFIGURATA
select 
		* 
from LIB_DomainValues 
	left join [CTL_Relations] on [REL_Type]='ISTANZA_ME' and [REL_ValueInput]='PROVINCE_IN_CUI_OPERA'
where DMV_DM_ID='GEO' and DMV_Cod not like '%-XXX' and DMV_COD=ISNULL(REL_ValueOutput,'M-1-11-ITA') 

	union

---PRENDE TUTTE LE REGIONI SE NON TROVA LA RELAZIONE
select 
	* 
from LIB_DomainValues 
	left join [CTL_Relations] on [REL_Type]='ISTANZA_ME' and [REL_ValueInput]='PROVINCE_IN_CUI_OPERA'
where DMV_DM_ID='GEO' and DMV_Cod not like '%-XXX' and  DMV_Level < '6' and LEFT(DMV_Father,len('M-1-11-ITA')) = 'M-1-11-ITA'
	  and REL_ValueOutput IS NULL
		
		union

---PRENDE TUTTE LE PROVINCE
select 
	* 
from LIB_DomainValues 
	left join [CTL_Relations] on [REL_Type]='ISTANZA_ME' and [REL_ValueInput]='PROVINCE_IN_CUI_OPERA'
where DMV_DM_ID='GEO' and DMV_Level='6' and DMV_Cod not like '%-XXX' and    LEFT(DMV_Father,len(ISNULL(REL_ValueOutput,'M-1-11-ITA'))) = ISNULL(REL_ValueOutput,'M-1-11-ITA') 


GO
