USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_TAB_MESSAGGI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Versione=2&data=2014-01-07&Attivita=51208&Nominativo=Enrico
CREATE view [dbo].[MAIL_TAB_MESSAGGI] as
select
	d.idmsg as iddoc
	,lngSuffisso as LNG
	, a.aziRagionesociale as RagioneSociale
	, case lngSuffisso when 'I' then mlngDesc_I when 'UK' then mlngDesc_UK
	        when 'E' then mlngDesc_E when 'FRA' then mlngDesc_FRA
	        else  mlngDesc_I end	as TipoDoc

	, cast(d.msgitype as varchar) + ';' + cast(d.msgisubtype as varchar) as TipoDocumento	

	, x.ProtocolloOfferta as Protocollo
	, 
	
	case lngsuffisso when 'I' then
	        convert( varchar , msgDataIns , 103 )
	else
	        convert( varchar , msgDataIns , 101 )
	 end as DataInvio
	
	, convert( varchar , msgDataIns , 108 ) as OraInvio	
	,x.Name as Titolo
	,p.pfuNome as pfuNome
	,p.pfuE_mail as pfuE_mail
	--,x.Object as Body
	,isnull(Object_Cover1,'') as Body
	,isnull(x.cig,'') as cig	
	,isnull(p1.pfuNome,'') as pfuNomeDest
	,isnull(p1.pfuE_mail,'') as pfuE_mailDest
	, isnull(a1.aziRagionesociale,'') as RagioneSocialeDest	
	, ProtocolloBando as ProtocolloBando	
	,
	case  when rtrim(isnull(ReceivedDataMsg,'')) = '' then ''
	       when isdate(substring(ReceivedDataMsg,1,10))=0 then ''
	else 
	        case lngsuffisso when 'I' then
	                convert( varchar , cast(substring(ReceivedDataMsg,1,10) as datetime) , 103 ) 
	        else
	                convert( varchar , cast(substring(ReceivedDataMsg,1,10) as datetime) , 101 ) 
	        end
	        
	end  as DataRicezione
	
	--,isnull(Object_Cover1,'') AS Object_Cover1

	,CASE NumProduct_BANDO_rettifiche
				WHEN '' THEN isnull(Object_Cover1,'')
				WHEN '0' THEN isnull(Object_Cover1,'')
				ELSE '<b>Bando Rettificato - </b> ' + isnull(Object_Cover1,'')
			END  AS Object_Cover1

	,case cast(d.msgitype as varchar) + ';' + cast(d.msgisubtype as varchar)
	        when '55;167' then
	           'Comunicazione dal ' + dbo.CNV_ESTESA('#ML.ML_NOMEPORTALE#','I') + '- Protocollo Procedura: ''' + ProtocolloBando + ''''
	           --'Comunicazione dal Portale Acquisti AF Soluzioni - Protocollo Procedura: "' + ProtocolloBando + '"'
	        when '55;186' then
	           'Offerta Inviata - Bando N. ''' + ProtocolloBando + ''''
			when '55;22' then 
					case TipoBando 
						when '2' then 'Docmanda di partecipazione Inviata - Bando N. ''' + ProtocolloBando + ''''
						when '1' then 'Manifestazione di interesse Inviata - Bando N. ''' + ProtocolloBando + ''''
	       			end 
	        else
	           'Documento inviato - Protocollo N. ''' + ProtocolloBando + ''''
	  end as ObjectMail	  
	  ,
	  
	  case lngsuffisso when 'I' then
	        convert(varchar(10),cast(x.ExpiryDate as datetime),103) 
		+ ' ' + convert(varchar(8),cast(x.ExpiryDate as datetime),108) 
	  else
	        convert(varchar(10),cast(x.ExpiryDate as datetime),101) 
		+ ' ' + convert(varchar(8),cast(x.ExpiryDate as datetime),108) 
	  end as ExpiryDate
	  
	  ,isnull(ImportoBaseAsta2,0) as ImportoBaseAsta
	  
	  ,dbo.GetDestinatari(x.iddoc) as ListaUtenti
	
      , case cast(d.msgitype as varchar) + ';' + cast(d.msgisubtype as varchar)
			when '55;22' then 
					case TipoBando 
						when '2' then 'Domanda di partecipazione'
						when '1' then 'Manifestazione di interesse'
	       			end 
	        else
	           ''
		end  as TipoDocEsteso	

	, case 
			when A1.azivenditore <> 0 then 'Operatore Economico'
			when A1.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaDestinatario

	, case 
			when A.azivenditore <> 0 then 'Operatore Economico'
			when A.aziacquirente <> 0 then 'Ente'
	  end as TipoAziendaMittente
	, '' as Attach_Grid

from tab_messaggi d
inner join TAB_MESSAGGI_FIELDS x on x.idmsg=d.idmsg
cross join Lingue
left join profiliutente p on p.idpfu = idmittente
left join aziende a on a.idazi = p.pfuidazi
inner join Document on dcmitype=d.msgitype and dcmisubtype=d.msgisubtype
left outer join Multilinguismo on dcmDescription = IdMultiLng 
left outer join profiliutente p1 on p1.idpfu = IdDestinatario
left outer join aziende a1 on a1.idazi = p1.pfuidazi

GO
