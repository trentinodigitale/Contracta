USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_STATO_RISPOSTA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MSG_LINKED_STATO_RISPOSTA] AS
SELECT 
CASE CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000)))
WHEN 0 THEN ''
ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 20)) 
END AS Fascicolo
,
case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldStato>', CAST(MSGTEXT AS VARCHAR(8000))) + 18, 20)) 
WHEN 1 THEN 'Saved'
WHEN 4 THEN 'Invalidate'
WHEN 2 then
CASE CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000)))
WHEN 0 THEN
'Sended'
ELSE

case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAdvancedState>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 20)) 
WHEN '' THEN
'Sended'


WHEN 1 THEN 'Confirmed'
WHEN 2 THEN 'Rejected'
WHEN 3 THEN 'Revoke'
WHEN 4 THEN 'InApprove'
WHEN 5 THEN 'NotApprove'
WHEN 6 THEN 'Correct'
WHEN 0 THEN

case CHARINDEX ('<AFLinkFieldAuctionState>', CAST(MSGTEXT AS VARCHAR(8000)))
WHEN 0 THEN
'Sended'
else
case dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldAuctionState>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 20)) 
WHEN 0 THEN 'Programmata'
WHEN 1 THEN 'InCorso'
WHEN 2 THEN 'Chiusa'
WHEN 3 THEN 'Annullata'
end
end 

end 


end	
end as StatoCollegati

, umIdPfu AS IdPfu

FROM TAB_MESSAGGI inner join TAB_UTENTI_MESSAGGI on	IdMsg = umIdMsg

INNER JOIN (

select max( IdMsg ) AS IdMsg 
FROM TAB_MESSAGGI
, TAB_UTENTI_MESSAGGI
WHERE 
IdMsg = umIdMsg
AND msgItype = 55
and msgisubtype IN (27,54,70,38,186)
AND umInput = 0
AND umstato=0

group by umIdPfu
,	 CASE CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000)))
WHEN 0 THEN ''
ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProtocolBG>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 20)) 
END 

) AS A ON A.IdMsg = TAB_MESSAGGI.IdMsg
GO
