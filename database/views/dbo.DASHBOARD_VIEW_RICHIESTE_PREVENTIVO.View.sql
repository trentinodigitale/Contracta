USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RICHIESTE_PREVENTIVO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_RICHIESTE_PREVENTIVO] as
select 

            idMsg , name , Object_Cover1 as Object , t.DMV_Cod as TipoAppaltoGara, ExpiryDate , CriterioAggiudicazioneGara , CriterioFormulazioneOfferte , ProtocolBG as Fascicolo, ReceivedOff 
, ProtocolloBando

      from TAB_MESSAGGI_FIELDS 
            left outer join LIB_DomainValues t on t.DMV_DM_ID  = 'Tipologia ' and t.DMV_CodExt = tipoappalto
            inner join dbo.TAB_UTENTI_MESSAGGI on umIdMsg = idMsg and umInput = 0
      where isubtype = 68 and stato <> 1
            and AdvancedState <> 3 
            and DataAperturaOfferte < convert( varchar(20) , getdate() , 121 ) 
            and isnull( ReceivedOff  , '' ) <> ''

GO
