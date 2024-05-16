USE [AFLink_TND]
GO
/****** Object:  View [dbo].[STRUTTURA_APPARTENENZA_FROM_UPD_ROW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[STRUTTURA_APPARTENENZA_FROM_UPD_ROW] as
select 
	id as  ID_FROM , id as LinkedDoc , 'Upd' as JumpCheck 
	, Descrizione, Cod_Uni_OU as CodiceIpa, centrodicosto,emailreferenteipa
	from  az_struttura  with (nolock)
		left join AZIENDE_CODICI_IPA with (nolock) on plant = cast ( IdAz  as varchar) + '#' + path





GO
