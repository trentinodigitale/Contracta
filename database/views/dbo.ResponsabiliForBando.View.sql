USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ResponsabiliForBando]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[ResponsabiliForBando] as 

	-- determina gli utenti coerenti per i riferimenti
	select a.idpfu , 
		case 
			when attvalue in ('GestoreAlboLavori') and DOC_ID = 'BANDO' then  'BANDO_ALBO_LAVORI'
			else DOC_ID
		end 
		as DOC_ID 
		, o.idpfu as [OWNER]
		from profiliUtenteAttrib a
		inner join LIB_Documents on DOC_ID in ( 'BANDO' , 'BANDO_SDA' ) 
		inner join profiliutente p on a.idpfu = p.idpfu
		inner join profiliutente o on o.pfuidazi = p.pfuIdAzi
		where 
			dztnome='Profilo'
			and 
			(
				( attvalue in ('ResponsabileAlbo')  and DOC_ID in ('BANDO' ) )
				or
				( attvalue in ('GestoreSDA')  and DOC_ID in ('BANDO_SDA' ) )
				or
				( attvalue in ('GestoreAlboLavori') and DOC_ID in ('BANDO' ) )
			)
		

GO
