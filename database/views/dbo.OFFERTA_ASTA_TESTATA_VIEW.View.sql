USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OFFERTA_ASTA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view  [dbo].[OFFERTA_ASTA_TESTATA_VIEW] as
select 
	d.* , b.* , 
	--F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK ,
	--case when F1_SIGN_LOCK <> 0 or F2_SIGN_LOCK <> 0 or F3_SIGN_LOCK <> 0 or F4_SIGN_LOCK <> 0 or isnull( F.nFirme , 0 ) <> 0  then 1
	--	else 0
	--	end as FIRMA_IN_CORSO
	 ba.tipodoc as TipoDocBando
	--,DF.FormulaEconomica as colonnatecnica
	--,M.MOD_Name as ModelloOfferta

	, a.DataScadenzaAsta
	, a.BaseCalcolo
	, a.AutoExt
	, a.Ext
	, a.TipoExt
	, a.TipoAsta
	, a.StatoAsta
	, a.RilancioMinimo

	, ba.azienda as  idAggiudicatrice
	, a.DataInizio
	
from CTL_DOC d 
	inner join Document_Bando  b on d.LinkedDoc = b.idHeader
	inner join Document_ASTA  a on d.LinkedDoc = a.idHeader
	inner join CTL_DOC ba on d.LinkedDoc = ba.id
	--left outer join CTL_DOC_SIGN s on s.idHeader = d.id
	---- verifica 
	--left outer join (
	--			select[DataInizio] d.idheader , sum( case when F1_SIGN_LOCK <> 0 then 1 else 0 end + case when F2_SIGN_LOCK <> 0 then 1 else 0 end ) as nFirme 
	--				from Document_MicroLotti_Dettagli d
	--						inner join Document_Microlotto_Firme f on d.id = f.idheader
	--						where Tipodoc = 'OFFERTA'
	--						group by d.idheader
	
	--			) as F on F.idheader = d.id
	--	left join Document_Modelli_MicroLotti_Formula DF on DF.CriterioFormulazioneOfferte= b.criterioformulazioneofferte and b.TipoBando=DF.Codice and DF.deleted = 0 
	---- recupera il modello utlizzato sui prodotti
	--left outer join CTL_DOC_SECTION_MODEL M on M.IdHeader = d.id and DSE_ID = 'PRODOTTI'




GO
