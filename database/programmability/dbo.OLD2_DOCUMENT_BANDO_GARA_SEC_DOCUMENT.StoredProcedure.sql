USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DOCUMENT_BANDO_GARA_SEC_DOCUMENT]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_DOCUMENT_BANDO_GARA_SEC_DOCUMENT] ( @DocName NVARCHAR(50) , @Section NVARCHAR(50) , @IdDoc INT , @idUser INT )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @idDocSimog INT = null
	DECLARE @idDocTed INT = null
	DECLARE @pcp_TipoScheda varchar(100) = ''
	DECLARE @moduliResult nvarchar(max) = ''
	DECLARE @GARE_IN_MODIFICA_O_RETTIFICA varchar(max) = ''
	DECLARE @pcp_StatoScheda varchar(200) = ''
	DECLARE @versioneSimog varchar(100) = ''
	DECLARE @Cottimo_Gara_Unificato_Attivo varchar(100) = ''
	declare @pcp_VersioneScheda as varchar(50)

	select top 1 @idDocSimog = id
		from ctl_doc s with(nolock) 
		where s.LinkedDoc = @IdDoc and s.TipoDoc in ( 'RICHIESTA_CIG', 'RICHIESTA_SMART_CIG' ) and s.Deleted = 0 and s.StatoFunzionale in ( 'InvioInCorso', 'Inviato' )

	select top 1 @idDocTed = id 
		from ctl_doc s2 with(nolock) 
		where s2.LinkedDoc = @IdDoc and s2.TipoDoc = 'DELTA_TED' and s2.Deleted = 0 and s2.StatoFunzionale in ( 'InvioInCorso', 'Inviato' )

	select @moduliResult = diz.DZT_ValueDef
		from LIB_Dictionary Diz with(nolock) 
		where Diz.DZT_Name='SYS_MODULI_RESULT'

	--prendo la versione simog in essere
	select @versioneSimog = diz.DZT_ValueDef
		from LIB_Dictionary Diz with(nolock) 
		where Diz.DZT_Name='SYS_VERSIONE_SIMOG'

	set @GARE_IN_MODIFICA_O_RETTIFICA = dbo.GetBandiInRettificaOModifica()

	SELECT @pcp_TipoScheda = pcp_TipoScheda , @pcp_VersioneScheda = pcp_VersioneScheda
		FROM Document_PCP_Appalto with(nolock)
		WHERE idHeader=@IdDoc

	IF @pcp_TipoScheda <> ''
	BEGIN

		SELECT top 1 @pcp_StatoScheda = statoScheda
			FROM Document_PCP_Appalto_Schede with(nolock)
			WHERE idHeader = @IdDoc and bDeleted = 0 and tipoScheda = @pcp_TipoScheda
			ORDER BY idRow desc

	END

	--vedo tramite parametro se il Cottimo è unificato alle Procedure di gara
	set @Cottimo_Gara_Unificato_Attivo = dbo.PARAMETRI('GROUP_Procedura','Cottimo_Gara_Unificato','ATTIVO','NO',-1 )

	select d.* , 
			b.Concessione , 
			b.TipoProceduraCaratteristica,
			case when @idDocSimog is null then 0 else 1 end as docRichiestaCig,
			dbo.attivoSimog() as attivoSimog,
			isnull(SUBSTRING(@moduliResult,266,1),0) as ATTIVA_COMPOSIZIONE_AZI_MANIFESTAZIONE,
			isnull(SUBSTRING(@moduliResult,267,1),0) as ATTIVA_COMPOSIZIONE_AZI_DOMANDA ,
			@GARE_IN_MODIFICA_O_RETTIFICA as GARE_IN_MODIFICA_O_RETTIFICA,

			case when ( dm.vatValore_FT <> '' and left( convert(varchar,getdate(), 126), 10) >= dm.vatValore_FT ) --SE LA DATA DELLA GARA è MAGGIORE O UGUALE DELLA DATA DI INIZIO ATTIVAZIONE OCP
						AND
					NOT ( b.ProceduraGara = '15477' and b.TipoBandoGara = '2' ) --SE SIAMO SU UN GIRO DI BANDO RISTRETA
						AND
					NOT ( b.ProceduraGara = '15478' and b.TipoBandoGara = '1' ) --O NEGOZIATA CON AVVISO
						AND
					NOT ( b.Divisione_lotti = '0' and @idDocSimog is null ) --SE LA PROCEDURA E' UNA MONOLOTTO PRIVA DELL'INTEGRAZIONE CON IL SIMOG 
				  then 'si'
				  else 'no'
			END AS Attiva_OCP,

			case when @idDocTed is null then 0 else 1 end as docRichiestaTED,

			case 
				when dm.vatValore_FT <> '' and left( convert(varchar,getdate(), 126), 10) >= dm.vatValore_FT then '1'
				else '0'
			end Show_Attrib_OCP

			, isnull(@versioneSimog, '') as SYS_VERSIONE_SIMOG
			, isnull(FaseConcorso,'') as FaseConcorso
			
			, @Cottimo_Gara_Unificato_Attivo as Cottimo_Gara_Unificato_Attivo
			
			, @pcp_TipoScheda as pcp_TipoScheda
			, isnull(@pcp_StatoScheda,'') as StatoSchedaPCP
			, @pcp_VersioneScheda as pcp_VersioneScheda
		from CTL_DOC d with (nolock)  
				inner join Document_Bando b with(nolock) on b.idHeader = d.Id
				left join DM_Attributi dm with(nolock) on dm.lnk = d.Azienda and dm.dztNome = 'DataAttivazioneOCP' and dm.idApp = 1
		where d.id = @IdDoc

END

GO
