USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_COM_DPE_ENTI_ADDFROM]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Versione=2&data=2014-01-16&Attivita=50092&Nominativo=Sabato
CREATE VIEW [dbo].[OLD2_COM_DPE_ENTI_ADDFROM]
AS
SELECT 
	IdAzi AS IndRow
     , aziIndirizzoLeg + ' - ' + aziLocalitaLeg + ' - ' + aziStatoLeg   AS Indirizzo
     , DM_1.vatvalore_ft     AS codicefiscale
    -- , *
	,[IdAzi], [aziTs], [aziLog], [aziDataCreazione], [aziRagioneSociale], [aziRagioneSocialeNorm], [aziIdDscFormaSoc], [aziPartitaIVA], [aziE_Mail], [aziAcquirente], [aziVenditore], [aziProspect], [aziIndirizzoLeg], [aziIndirizzoOp], [aziLocalitaLeg], [aziLocalitaOp], [aziProvinciaLeg], [aziProvinciaOp], [aziStatoLeg], [aziStatoOp], [aziCAPLeg], [aziCapOp], [aziPrefisso], [aziTelefono1], [aziTelefono2], [aziFAX], [aziLogo], [aziIdDscDescrizione], [aziProssimoProtRdo], [aziProssimoProtOff], [aziGphValueOper], [aziDeleted], [aziDBNumber], [aziAtvAtecord], [aziSitoWeb], [aziCodEurocredit], [aziProfili], [aziProvinciaLeg2], [aziStatoLeg2], [aziFunzionalita], [CertificatoIscrAtt], [TipoDiAmministr], [aziLocalitaLeg2], [daValutare], [aziNumeroCivico]
	 , case 
		   when A.azideleted=1 and ISNULL(d3.vatValore_FT,'') = '1'
				then 'Eliminato'
		   when A.azideleted=1 and ISNULL(d3.vatValore_FT,'') = ''
		   		then 'Cessato'
		   else	'Attivo'
	 end  as statoente
    , SUBSTRING ( dmv_father ,1 , charindex('-',dmv_father)-1 ) as PrimoLivelloStruttura
	, d1.vatValore_FT  as TIPO_AMM_ER
	--, isnull(d7.vatValore_FT,'no') as Attiva_OCP	 
	 , case
		when d7.vatValore_FT is null or d7.vatValore_FT = '' then 'no'
		else d7.vatValore_FT
		end as Attiva_OCP 

  FROM 
     Aziende A with (nolock)
		 LEFT OUTER JOIN DM_Attributi  AS DM_1  with (nolock) ON A.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'codicefiscale' 
		 left outer join dbo.DM_Attributi d3  with (nolock) on d3.dztNome = 'ELIMINATA' and d3.idApp = 1 and d3.lnk = A.idazi
		 left outer join dbo.DM_Attributi d1 on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = A.idazi
		 left outer join LIB_DomainValues with (nolock) on dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
		 left join dbo.dm_attributi d7 with(nolock) ON d7.dztNome = 'Attiva_OCP' and d7.idApp = 1 and d7.lnk = a.IdAzi 
 WHERE 
    aziDeleted = 0
    and aziAcquirente  = 3
   


   





GO
