USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_OFFERTE_COMUNICAZIONI_CONTRATTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







  
  CREATE view [dbo].[OLD2_VIEW_OFFERTE_COMUNICAZIONI_CONTRATTI] as
  
  select  
	 C.id AS IdMsg
	, p.idpfu
	--,42745 as IdPfu
     , '' AS msgIType
	--, ''  AS msgISubType
	,case C.Tipodoc
	   when 'DOMANDA_PARTECIPAZIONE' then '22'
	   else ''	  
     end as msgISubType

    , 
	case 
		when 
		C.TipoDoc = 'RISPOSTA_CONCORSO' then --'' -- da capire se visualizzarr altro ad es. Anonimo
			case 
				when Proceduragara='15586' then 'Risposta Concorso di Idee'
				when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInSingolaFase'  then 'Risposta Concorso di Progettazione'
				when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInDueFasi' and ISNULL(faseconcorso,'')='prima' then 'Risposta Concorso di Progettazione I fase'
				when Proceduragara='15587' and isnull(TipoProceduraCaratteristica,'') ='ConcorsoInDueFasi'  and ISNULL(faseconcorso,'')='seconda' then 'Risposta Concorso di Progettazione II fase'
			end


		else C.Titolo
	end as Name

	, 0 as bread
	, cast(C.body as nvarchar(4000)) as Oggetto	
    , C.ProtocolloRiferimento AS ProtocolloBando   
	, C.Fascicolo       
    , C.Protocollo as ProtocolloOfferta
    ,  case C.statodoc 
		when 'saved' then '1' 
		else '2' 
	  end  as StatoGD
	, '' as AdvancedState
    , convert(varchar(20),C.DataInvio , 20 ) as ReceivedDataMsg
    , C.idpfu  as IdMittente
    , '0' as Cifratura
    , '' as azipartitaiva
    , '' as idAziPartecipante
	, C.TipoDoc as DocType
    , 
		case
		when C.tipodoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP','PDA_COMUNICAZIONE_RISP','OFFERTA','OFFERTA_ASTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE','RITIRA_OFFERTA','RISPOSTA_CONCORSO' ) then
			case C.StatoDoc 
				when 'Invalidate' then 'Annullata'
				else C.StatoDoc
				end 
		when C.tipodoc in ('COMUNICAZIONE_OE','COMUNICAZIONE_OE_RISP','VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN') then
			C.StatoDoc
		when C.tipodoc in ('CONTRATTO_GARA_FORN') then
			case C.StatoDoc 
				when 'Confirmed' then 'Confirmed'
				when 'Sended'  then 'Received'
				when 'Invalidate' then 'Annullata'
				else 'Received'
			end
		when C.tipodoc = 'PDA_COMUNICAZIONE_GARA' and C.JumpCheck in ('0-RETTIFICA_ECONOMICA_OFFERTA','0-RETTIFICA_TECNICA_OFFERTA') then
			case C.StatoDoc 
				when 'Sended'  then 'Sended'
				when 'Invalidate' then 'Annullata'
				else 'Received'
			end
		else
			case C.StatoDoc 
				when 'Sended'  then 'Received'
				when 'Invalidate' then 'Annullata'
				else 'Received'
			end
	   end as  StatoCollegati
    , case 
		when C.TipoDoc='VERIFICA_REGISTRAZIONE' then 'VERIFICA_REGISTRAZIONE_FORN'
		--when TipoDoc='CONTRATTO_GARA' then 'CONTRATTO_GARA_FORN'
		when C.TipoDoc='SCRITTURA_PRIVATA' then 'SCRITTURA_PRIVATA_FORN'
			else
			C.Tipodoc
	 	end  as OPEN_DOC_NAME

	, case  
		  
		when C.TipoDoc in ('PDA_COMUNICAZIONE_OFFERTA_RISP','OFFERTA_ASTA','OFFERTA','RITIRA_OFFERTA') then '186'
		when C.TipoDoc in ('SCRITTURA_PRIVATA', 'CONTRATTO_GARA_FORN') then 'SCRITTURA_PRIVATA'		
		when C.Tipodoc ='DOMANDA_PARTECIPAZIONE' then 'DOMANDA_PARTECIPAZIONE'
		when C.Tipodoc ='RISPOSTA_CONCORSO' then 'RISPOSTA_CONCORSO'

		else 'PDA_COMUNICAZIONE_GARA' 

		end as Folder

	, '' as TipoBando

	, Cig

	, L.azienda as Azi_Ente
	, convert(varchar(20),C.DataInvio , 20 ) as ReceivedDataMsgA
	, b.TipoBandoGara

from CTL_DOC  C with(nolock) 
		--PER ESCLUDERE LE COMUNICAZIONI FATTE A FRONTE DI UN CANCELLA_ISCRIZIONE, CREAVANO DUE FOLDER "Comunicazioni" LATO O.E.
		inner join CTL_DOC L with(nolock) on L.id=C.linkeddoc and L.TipoDoc <> 'CANCELLA_ISCRIZIONE'
		left join document_bando B with(nolock) on B.idheader=C.linkeddoc 
		
		--inner join ProfiliUtente p with(nolock) on (Destinatario_User=p.IdPfu ) or (( Destinatario_azi=pfuidazi  or  azienda = pfuidazi ) and isnull( Destinatario_User , 0 ) = 0 ) 
		inner join ProfiliUtente p with(nolock) on ( C.Destinatario_azi=pfuidazi or C.azienda = pfuidazi )  
		left outer join ProfiliUtenteAttrib pa with(nolock) on pa.idpfu = p.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
where 

	(
	  ( C.TipoDoc in ( 'PDA_COMUNICAZIONE_GARA') and C.StatoDoc='Sended' and ( (C.Destinatario_User=p.IdPfu ) or (( C.Destinatario_azi=pfuidazi  or  C.azienda = pfuidazi ) and isnull( C.Destinatario_User , 0 ) = 0 ) ) )
	  or 
	  ( C.TipoDoc in ( 'PDA_COMUNICAZIONE_OFFERTA' ) and C.StatoDoc='Sended' )
	  or 
	  ( C.TipoDoc in (  'COMUNICAZIONE_OE','PDA_COMUNICAZIONE_RISP' ,  'PDA_COMUNICAZIONE_OFFERTA_RISP' , 'OFFERTA' ,'VERIFICA_REGISTRAZIONE','VERIFICA_REGISTRAZIONE_FORN' , 'OFFERTA_ASTA','MANIFESTAZIONE_INTERESSE' ,'DOMANDA_PARTECIPAZIONE' ,'RITIRA_OFFERTA','RISPOSTA_CONCORSO' ) )
	  or 
	 ( C.TipoDoc in ( 'COMUNICAZIONE_OE_RISP' ) and C.StatoDoc='Sended' )	  
	  or 
	  ( C.TipoDoc in ( 'SCRITTURA_PRIVATA', 'CONTRATTO_GARA_FORN') and C.StatoFunzionale <> 'InLavorazione' )
   )
   and 
   ( 
		( C.TipoDoc  not in ( 'OFFERTA' , 'OFFERTA_ASTA','MANIFESTAZIONE_INTERESSE','RITIRA_OFFERTA','DOMANDA_PARTECIPAZIONE' ,'RISPOSTA_CONCORSO') )
		or
		( C.TipoDoc  in ( 'OFFERTA' , 'OFFERTA_ASTA','MANIFESTAZIONE_INTERESSE','RITIRA_OFFERTA','DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO')  and ( C.idpfu = p.idpfu or C.idpfuincharge = p.idpfu or pa.idpfu is not null  ) )
	)

	and C.deleted = 0 
	and ISNULL(C.JumpCheck,'') <> '0-SOSPENSIONE_ALBO' --in questo modo non ritorna le comunicazione di sospensione per l'albo


GO
