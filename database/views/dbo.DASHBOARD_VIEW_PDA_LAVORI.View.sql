USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PDA_LAVORI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DASHBOARD_VIEW_PDA_LAVORI]  AS
--Versione=3&data=2012-09-12&Attvita=39396&Nominativo=enrico
--Versione=4&data=2013-01-16&Attvita=40053&Nominativo=Sabato
--Versione=5&data=2013-08-28&Attvita=43317&Nominativo=enrico
--Versione=5&data=2014-02-18&Attvita=52507&Nominativo=enrico
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
			  FROM TAB_MESSAGGI tm
				 , TAB_UTENTI_MESSAGGI
				 , TAB_MESSAGGI_FIELDS t
			 WHERE t.IdMsg = umIdMsg and
                  tm.IdMsg = umIdMsg
			   AND msgItype = 55
			   AND msgisubtype = 169
			   AND umInput = 0
			   AND umStato = 0
			   AND umIdPfu <> -10

		union all 

			select 
				 d.id as IdMsg
				 , d.IdPfu
				 , 0 as msgIType
				 , 0 as msgISubType
				 , -1 as msgelabwithsuccess
				 , d.titolo as Name
				 , isnull( f.NameBG , b.titolo ) as NameBG
				 , d.ProtocolloRiferimento as ProtocolloBando
				 ,isnull( t.DataAperturaOfferte , db.DataAperturaOfferte ) as DataAperturaOfferte
				 ,  case 
						when len(f.DataIISeduta)<10 then ''
						else  f.DataIISeduta
					end  as  DataIISeduta
				 ,1 /*t.stato*/ AS StatoGD
				 ,f.FaseGara	
				 ,d.Tipodoc as OPEN_DOC_NAME
				 ,isnull( f.tipoappalto , db.tipoappaltogara ) as tipoappalto
				 ,isnull( f.proceduragara , db.proceduragara ) as proceduragara
			from ctl_doc d
				inner join Document_PDA_TESTATA t on d.id = t.idheader
				left outer join TAB_MESSAGGI_FIELDS f on f.idmsg = d.LinkedDoc
				left outer join CTL_DOC b on d.linkedDoc = b.id and b.TipoDoc = 'BANDO_GARA' 
				left outer join Document_bando db on db.idheader = b.id 
				where d.tipodoc = 'PDA_MICROLOTTI' and d.deleted = 0 and  isnull(d.JumpCheck,'') in ( '' , 'BANDO_GARA' )  
				


		) as p
				left outer join Document_Repertorio r on r.ProtocolloBando = p.ProtocolloBando




GO
