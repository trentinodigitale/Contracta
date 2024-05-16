USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MODULO_TEMPLATE_REQUEST_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD_MODULO_TEMPLATE_REQUEST_VIEW] as

select 
	
	C.* ,
	case 
		when isnull(c1.tipodoc,'') in ('DOMANDA_PARTECIPAZIONE','MANIFESTAZIONE_INTERESSE','OFFERTA','RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA')   then ''
		when isnull(c1.tipodoc,'') like 'ISTANZA_%' and  A.aziStatoLeg2 IS NULL then ''
		else P.pfuCodiceFiscale 
	end as codicefiscale,
	--colonnatecnica per capire se posso "Modifica Dati" sul DGUE
	case when C1.StatoFunzionale <> 'InLavorazione'  or  ISNULL(c1.SIGN_HASH,'')<>'' or ISNULL(c1.SIGN_LOCK,'')<>''  then 'no'
		 else 'si' 
	end as colonnatecnica

from ctl_doc C with (nolock)
	left join ProfiliUtente P with (nolock) on P.IdPfu=C.idPfuInCharge	
	left join  ctl_doc C1 with (nolock) on C1.id= C.LinkedDoc 
	--INFO PER CAPIRE SE APPARTIENE AD UN AZIENDA ESTERA NON FACCIAMO IL CONTROLLO DEL CF SU ALLEGA DGUE FIRMATO PER I DGUE DELLE ISTANZE
	left join Aziende A with (nolock) on A.IdAzi=P.pfuIdAzi and ( ISNULL(A.aziStatoLeg2,'M-1-11-ITA' ) = 'M-1-11-ITA' or A.aziStatoLeg2='' )


GO
