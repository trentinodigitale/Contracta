USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_SchedaPrecontratto_Controlli]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Document_SchedaPrecontratto_Controlli] as
select * , idAziControllata as Fornitore , idDoc_ContGara_For as CONTROLLIGrid_ID_DOC , 'COM_CONTROLLI_GARA' as CONTROLLIGrid_OPEN_DOC_NAME
from Document_Aziende_Comunicazioni 
	inner join (
			select s.Id, s.idAggiudicatrice as idAzi , s.ProtocolloBando as ProtocolloBando
				from Document_SchedaPrecontratto s 
				inner join aziende a on a.idazi = s.idAggiudicatrice and a.aziIdDscFormaSoc <> '845326'
			union
			select s.Id, e.idAzi as idAzi , s.ProtocolloBando as ProtocolloBando
				from Document_SchedaPrecontratto s 
				inner join aziende a on a.idazi = s.idAggiudicatrice and a.aziIdDscFormaSoc in ('836418','845321','845323','845322','845320')
				INNER join Document_Aziende_Esecutrici e on s.idAggiudicatrice = e.idAzi and Esecutrice = 'si' and s.ProtocolloBando = e.ProtocolloBando
			union 
			select s.Id, idAziPartecipante as idAzi, ProtocolloBando  
				from Document_SchedaPrecontratto s 
				inner join aziende a on a.idazi = s.idAggiudicatrice and a.aziIdDscFormaSoc = '845326'
				INNER JOIN Document_Aziende_RTI r ON R.idAziRTI = s.idAggiudicatrice AND R.ISoLD = 0  

	) a on idAziControllata = a.idAzi and Protocol = a.ProtocolloBando
where Tipocomunicazione <> 'DURC2'and Tipocomunicazione <> 'CANC_FALLIMENTARE_x'

GO
