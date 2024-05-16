USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RiferimentiForBando]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





 CREATE view [dbo].[RiferimentiForBando] as 

	-- determina gli utenti coerenti per i riferimenti
	select a.idpfu , 
		case 
			when attvalue in ('GestoreAlboLavori','IstruttoreAlboLavori') and DOC_ID = 'BANDO' then  'BANDO_ALBO_LAVORI'
			else DOC_ID
		end 
		as DOC_ID 
		, o.idpfu as [OWNER]
		from profiliUtenteAttrib a with (nolock , index (IX_ProfiliUtenteAttrib_dztNome_attValue_IdPfu) )
			inner join LIB_Documents with (nolock , index (IX_LIB_Documents_DOC_ID) ) on DOC_ID in ( 'BANDO' , 'BANDO_SDA' ,'BANDO_GARA' , 'BANDO_SEMPLIFICATO', 'BANDO_ASTA', 'BANDO_CONSULTAZIONE', 'BANDO_CONCORSO') 
			inner join profiliutente p with (nolock, index(IX_ProfiliUtente) ) on a.idpfu = p.idpfu 
			inner join profiliutente o with (nolock, index (UN_Login) ) on o.pfuidazi = p.pfuIdAzi
		where 
			dztnome='Profilo'
			and 
			(
				( attvalue in ('ResponsabileAlbo','IstruttoreAlbo')  and DOC_ID in ('BANDO' ) )
				or
				( attvalue in ('GESTORE_ALBO_FORN','ISTRUTTORE_ALBO_FORN')  and DOC_ID in ('BANDO' ) )
				or
				( attvalue in ('GestoreSDA','IstruttoreSDA')  and DOC_ID in ('BANDO_SDA' ) )
				or
				( attvalue in ('ProfiloRdO','RupProfiloC','ACQUISTI')  and DOC_ID in ('BANDO_GARA' , 'BANDO_CONCORSO' ) )
				or
				( attvalue in ('BandoSemplificato')  and DOC_ID in ('BANDO_SEMPLIFICATO' ) )
				or
				( attvalue in ('GestoreAlboLavori','IstruttoreAlboLavori')  and DOC_ID in ('BANDO' ) )
				or
				( attvalue in ('RupProfiloC','GareInformali')  and DOC_ID in ('BANDO_ASTA' ) )
				or
				( attvalue in ('CONS_PREL_MERCATO')  and DOC_ID in ('BANDO_CONSULTAZIONE' ) )
			)
		
		



GO
