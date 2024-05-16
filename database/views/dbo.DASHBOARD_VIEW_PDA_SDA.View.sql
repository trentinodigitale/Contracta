USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PDA_SDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PDA_SDA]  AS
--Versione=1&data=2013-01-16&Attvita=40053&Nominativo=Sabato
select 
	p.* ,
	case when isnull( r.StatoRepertorio , '' ) = '' then 'InCorso'
		else r.StatoRepertorio 
	end as StatoRepertorio 

from 
		(

			select 
				 d.id as IdMsg
				 , d.IdPfu
				 , 0 as msgIType
				 , 0 as msgISubType
				 , -1 as msgelabwithsuccess
				 , d.titolo as Name
				 --, f.NameBG
--				 , d.ProtocolloRiferimento as ProtocolloBando
				 ,t.DataAperturaOfferte
--				 ,  case 
--						when len(f.DataIISeduta)<10 then ''
--						else  f.DataIISeduta
--					end  as  DataIISeduta
--				 ,1 /*t.stato*/ AS StatoGD
				 ,d.StatoFunzionale	
				 ,d.Tipodoc as OPEN_DOC_NAME
				, f.Body
				,se.ProtocolloBando 
				--,bs.ProtocolloBando as ProtocolloRiferimento


			from ctl_doc d
				inner join Document_PDA_TESTATA t on d.id = t.idheader
				inner join CTL_DOC f on f.id = d.LinkedDoc -- bando semplifiacto
				inner join document_bando se on se.idheader = f.id 
				where d.tipodoc = 'PDA_MICROLOTTI' and d.deleted = 0 and d.JumpCheck <> ''


		) as p
				left outer join Document_Repertorio r on r.ProtocolloBando = p.ProtocolloBando
GO
