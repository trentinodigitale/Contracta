USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONSULTAZIONE_GARE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_CONSULTAZIONE_GARE] as

select 
	C.id,
	C.tipodoc,
	C.idpfu,
	C.fascicolo,
	C.Data,
	C.Protocollo,
	C.Titolo as Name,
	C.StatoFunzionale,
	C.Body as Oggetto,
	'BANDO_CONSULTAZIONE' as OPEN_DOC_NAME,
	b.DataScadenzaOfferta as ExpiryDate,
	ISNULL(Appalto_Verde,'no') as Appalto_Verde,
	ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale ,
	case 
				when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
				when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
				when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
	end as Bando_Verde_Sociale,
	ISNULL(RecivedIstanze ,0) as ReceivedOff ,
	ISNULL(ReceivedQuesiti,0) as ReceivedQuesiti
	
	from ctl_doc C with(NOLOCK)
	
		inner join Document_Bando b with(NOLOCK) on C.id = b.idheader

		where C.deleted=0 and c.TipoDoc='BANDO_CONSULTAZIONE'

union all

--per la visibilità ai RUP
select 
	C.id,
	C.tipodoc,
	RUP.Value AS IdPfu,
	C.fascicolo,
	C.Data,
	C.Protocollo,
	C.Titolo as Name,
	C.StatoFunzionale,
	C.Body as Oggetto,
	'BANDO_CONSULTAZIONE' as OPEN_DOC_NAME,
	b.DataScadenzaOfferta as ExpiryDate,
	ISNULL(Appalto_Verde,'no') as Appalto_Verde,
	ISNULL(Acquisto_Sociale,'no') as Acquisto_Sociale ,
	case 
				when Appalto_Verde='si' and Acquisto_Sociale='si' then '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">&nbsp;<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">'  
				when Appalto_Verde='si' and Acquisto_Sociale='no' then  '<img title="Appalto Verde" alt="Appalto Verde" src="../images/Appalto_Verde.png">' 
				when Appalto_Verde='no' and Acquisto_Sociale='si' then  '<img title="Acquisto Sociale" alt="Acquisto Sociale" src="../images/Acquisto_Sociale.png">' 
	end as Bando_Verde_Sociale,
	ISNULL(RecivedIstanze ,0) as ReceivedOff ,
	ISNULL(ReceivedQuesiti,0) as ReceivedQuesiti

	from ctl_doc C with(NOLOCK)
	
		inner join Document_Bando b with(NOLOCK) on C.id = b.idheader
		inner join CTL_DOC_Value  RUP with(NOLOCK) on C.id = RUP.idheader and RUP.DSE_ID='InfoTec_comune' and RUP.dzt_name='UserRUP' and isnull( RUP.Value , 0 ) <> cast( c.IdPfu as varchar(20) )
	
	where C.deleted=0 and c.TipoDoc='BANDO_CONSULTAZIONE'



GO
