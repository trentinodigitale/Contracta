USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CN16_MOTIVO_ESCLUSIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[E_FORMS_CN16_MOTIVO_ESCLUSIONE] ( @idProc int , @idUser int = 0, @extraParams nvarchar(4000) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- Il recupero dati è superfluo, sono tutti dati costanti. essendo tutti moduli obbligatori del DGUE li prendiamo tutti
	-- che inseriamo in questa stored. in futuro se sarà necessario introdurremo una relazione o altro.
	CREATE TABLE #criteri_esclusione
	(
		code varchar(100),
		descr nvarchar(1000)
	)

	INSERT INTO #criteri_esclusione (code, descr )
		VALUES  ('bankruptcy', 'Fallimento' ), -- D.3.4
				('corruption', 'Corruzione'), -- D.1.2
				('cred-arran', 'Concordato preventivo con i creditori'), -- D.3.6
				('crime-org', 'Partecipazione a un''organizzazione criminale'), -- D.1.1
				('distorsion', 'Accordi con altri operatori economici intesi a falsare la concorrenza'), -- D.3.8
				('envir-law', 'Violazione di obblighi in materia di diritto ambientale'), -- D.3.1
				('finan-laund','Riciclaggio di proventi di attività criminose o finanziamento del terrorismo'), -- D.1.5
				('fraud', 'Frode'), -- D.1.3
				('human-traffic', 'Lavoro minorile e altre forme di tratta di esseri umani'), -- D.1.6
				('labour-law','Violazione degli obblighi in materia di diritto del lavoro'), -- D.3.3
				('misrepresent','Colpevole di false dichiarazioni, non è stato in grado di fornire i documenti richiesti e ha ottenuto informazioni riservate relative a tale procedura'), -- D.3.12
				('nati-ground', 'Motivi di esclusione previsti esclusivamente dalla legislazione nazionale'), -- D.4.1
				('partic-confl', 'Conflitto di interessi legato alla partecipazione alla procedura di appalto'), -- D.3.9
				('prep-confl', 'Partecipazione diretta o indiretta alla preparazione della procedura di appalto'), -- D.3.10
				('prof-misconduct', 'Gravi illeciti professionali'), -- D.3.7
				('sanction','Cessazione anticipata, risarcimento danni o altre sanzioni comparabili'), -- D.3.11
				('socsec-law', 'Violazione degli obblighi in materia di diritto sociale'), -- D.3.2
				('socsec-pay', 'Pagamento dei contributi di sicurezza sociale'), -- D.2.2
				('tax-pay', 'Pagamento di imposte'), -- D.2.1
				('terr-offence', 'Reati terroristici o reati connessi alle attività terroristiche') -- D.1.4

	-------------
	-- OUTPUT ---
	-------------
	select code as EXLUSION_CODE, descr as EXLUSION_DESCR from #criteri_esclusione
	
	drop table #criteri_esclusione


END
GO
