USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PDA_COTTIMO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PDA_COTTIMO]  AS
select 
	p.* ,
	case  when RIGHT(p.ProtocolloBando, 2) = '07'  and p.ProtocolloBando <> '053/2007' THEN 'Archiviato'
                       when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 

from 
		(
			SELECT t.IdMsg
				 , umIdPfu AS IdPfu
				 , msgIType
				 , msgISubType
				 , msgelabwithsuccess
				 , t.Name
				 ,t.NameBG
				 ,t.ProtocolloBando
				 --,t.DataAperturaOfferte
				 ,case 
						when len(t.DataAperturaOfferte)<10 then ''
						else  t.DataAperturaOfferte
					end  as  DataAperturaOfferte
				 ,case 
						when len(t.DataIISeduta)<10 then ''
						else  t.DataIISeduta
					end  as  DataIISeduta
				 ,t.stato AS StatoGD
				 ,t.FaseGara
				 , '' as OPEN_DOC_NAME
				 ,t.tipoappalto
				 ,t.proceduragara
				,t.CIG
				,t.Object_Cover1 as Object
			  FROM TAB_MESSAGGI tm
				 , TAB_UTENTI_MESSAGGI
				 , TAB_MESSAGGI_FIELDS t
			 WHERE t.IdMsg = umIdMsg and
                  tm.IdMsg = umIdMsg
			   AND msgItype = 55
			   AND msgisubtype = 65
			   AND umInput = 0
			   AND umStato = 0
			   AND umIdPfu <> -10

		union all 

			select 
				 d.id as IdMsg
				 , IdPfu
				 , 0 as msgIType
				 , 0 as msgISubType
				 , -1 as msgelabwithsuccess
				 , d.titolo as Name
				 , f.NameBG
				 , d.ProtocolloRiferimento as ProtocolloBando
				 ,t.DataAperturaOfferte
				 ,  case 
						when len(f.DataIISeduta)<10 then ''
						else  f.DataIISeduta
					end  as  DataIISeduta
				 ,1 /*t.stato*/ AS StatoGD
				 ,f.FaseGara	
				 ,Tipodoc as OPEN_DOC_NAME
				 ,f.tipoappalto
				 ,f.proceduragara
				 ,f.CIG
				,f.Object_Cover1 as Object
			from ctl_doc d
				inner join Document_PDA_TESTATA t on d.id = t.idheader
				inner join TAB_MESSAGGI_FIELDS f on f.idmsg = d.LinkedDoc
				where tipodoc = 'PDA_MICROLOTTI' and d.deleted = 0 and isnull(JumpCheck,'') = ''
					and statofunzionale <> 'VERIFICA_AMMINISTRATIVA'


		) as p
				left outer join Document_Repertorio r on r.ProtocolloBando = p.ProtocolloBando


GO
