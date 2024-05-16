USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ctl_mail_view_dinamic_subproc]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[ctl_mail_view_dinamic_subproc] as
Select 
	id,
	 case when Typedoc in ( 'RETTIFICA_BANDO','PROROGA_BANDO','BANDO_REVOCATO') then id else iddoc end as iddoc,
	idUser,
	case when Typedoc='COMUNICAZIONE_REVOCA_BANDO_SDA' then 'REVOCA_BANDO' 
		 when Typedoc='SOLLECITO_VALUTAZIONE_OFFERTA_INDICATIVA' then 'ISTANZA_SDA_FARMACI' 
		 when Typedoc='BLOCCO_INVIO_BANDO_SEMPLIFICATO' then 'BANDO_SEMPLIFICATO' 
		 when TypeDoc = 'QUESTIONARIO_FORNITORE_MAIL' then 'ISTANZA_AlboOperaEco_QF'
	else Typedoc end 	
	as Typedoc ,	
	case when Typedoc='RUBRICA_ENTE' then 'MAILUTENTI'
		 when Typedoc in ('MAIL_CONVENZIONE_SOGLIA_SUPERATA','MAIL_CONVENZIONE_SOGLIA_REGREDITA') then 'NOTIFICA_CONVENZIONE'	
	else 'SEND_MAIL' end
    as ProcName 
	
 from CTL_MAIL 
		where State='0'


GO
