using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.Report
{
	public class ESPD_BASE_FUNCTIONSModel : PageModel
	{

		public static CommonDbFunctions cdf = new CommonDbFunctions();
		public static CommonDbFunctions objDB_MTR = new CommonDbFunctions();
		public static string objDocument_Id;
		public static string strSecName;


		public void OnGet()
		{

		}

		//'-- centralizzare la funzione	
		public static void LoadDocument(string g_idDoc, ref Dictionary<object, object> g_col, ref Dictionary<object, object> g_uuid, ref Dictionary<object, object> g_Iterazioni)
		{

			objDocument_Id = "MODULO_TEMPLATE_REQUEST";
			strSecName = "DOC_SEC_MEM_" + objDocument_Id + "_" + g_idDoc;

			//'-- verifico se il documento è in memoria, in questo caso recupero la colelzione dalla memoria

			//'-- altrimenti lo carico dal db 
			//dim rs

			TSRecordSet rs = cdf.GetRSReadFromQuery_("SELECT DZT_Name, isnull(Value,'') as Value from ctl_doc_value with(nolock) where idheader = " + g_idDoc + " and DSE_ID = 'MODULO'  order by idrow ", ApplicationCommon.Application.ConnectionString);


			g_col = new Dictionary<object, object>();//CreateObject("Scripting.Dictionary")

			g_uuid = new Dictionary<object, object>();//CreateObject("Scripting.Dictionary")

			g_Iterazioni = new Dictionary<object, object>();//CreateObject("Scripting.Dictionary")

			if (rs.RecordCount > 0)
			{
				rs.MoveFirst();

				while (!rs.EOF)
				{
					g_col.Add(CStr(rs["DZT_Name"]), rs.Fields["Value"]);
					rs.MoveNext();
				}
			}

			//'-- CARICO IN UNA COLLEZIONE DEDICATA GLI UUID

			rs = cdf.GetRSReadFromQuery_("SELECT DZT_Name, isnull(Value,'') as Value from ctl_doc_value with(nolock) where idheader = " + g_idDoc + " and DSE_ID = 'UUID' and row = 0  order by idrow ", ApplicationCommon.Application.ConnectionString);

			if (rs.RecordCount > 0)
			{
				rs.MoveFirst();

				while (!rs.EOF)
				{
					g_uuid.Add(CStr(rs["DZT_Name"]), rs.Fields["Value"]);
					rs.MoveNext();
				}
			}

			//'-- carico le iterazioni dei gruppi

			rs = cdf.GetRSReadFromQuery_("SELECT * from ctl_doc_value with(nolock) where idheader = " + g_idDoc + " and DSE_ID = 'ITERAZIONI'  order by idrow ", ApplicationCommon.Application.ConnectionString);

			//set g_Iterazioni = CreateObject("Scripting.Dictionary")

			if (rs.RecordCount > 0)
			{
				rs.MoveFirst();

				while (!rs.EOF)
				{
					g_Iterazioni.Add(CStr(rs["DZT_Name"]), rs.Fields["Value"]);
					rs.MoveNext();
				}
			}
		}

		public static string getTecDateNoTime(dynamic data)
		{
			if (!string.IsNullOrEmpty(CStr(data)))
			{
				return Strings.Left(data, 10);
			}
			return "";
		}

		public static string normalizeUUID(object uuid)
		{

			string outUUI = "";
			//'outUUI = uuid

			string caratteriValidi = "0123456789-qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";

			if (!string.IsNullOrEmpty(CStr(uuid)))
			{
				for (int i = 1; i <= CStr(uuid).Length; i++)
				{
					string carattere = Strings.Mid(CStr(uuid), i, 1);

					//'-- se il carattere rientra nel subset consentito lo aggiunto all'output
					if (Strings.InStr(caratteriValidi, carattere) > 0)
					{
						outUUI = outUUI + carattere;
					}
				}
			}

			return outUUI;
		}

		//'-- recupera dal vettore delle iterazioni l'indice del campo per ogni livello e compone il nome univoco dell'attributo
		public static string GetNameFieldIterato(string FIELD, int[] VettoreIterazioni, string Base_o_Campo)
		{
			int i;
			string ret = "";
			string[] v;
			int vn;

			v = Strings.Split(FIELD, "_");

			vn = (v.Length - 1);

			if (Base_o_Campo == "B")
			{
				vn = vn - 1;
			}

			//'-- se richiedo la base mi serve il campo per memorizzare quel elemento quante iterazioni ha
			//'-- quindi devo escludere la numerazione delle iterazioni

			for (i = 0; i <= vn; i++)
			{
				if (i > 0)
				{
					ret = ret + "_";

				}

				if (VettoreIterazioni[i + 1] == 0)
				{
					ret = ret + v[i];
				}
				else
				{
					ret = ret + v[i] + "(" + VettoreIterazioni[i + 1] + ")";
				}
			}

			//'-- se ho escluso l'ultimo lo devo aggiungere senza l'iterazione
			if (Base_o_Campo == "B")
			{
				if (i > 0)
				{
					ret = ret + "_";
				}
				ret = ret + v[i];
			}

			return ret;
		}

		public static void DrawLegislation(object idModulo, EprocResponse htmlToReturn)
		{
			string SQL = "select  isnull( DescrizioneEstesa , '' ) as DescrizioneEstesa,  UUID  "
					+ " from CTL_DOC m with(nolock) "
					+ "		inner join DOCUMENT_REQUEST_GROUP r with(nolock) on m.id = r.idHeader "
					+ " where   m.id = " + idModulo + " and  isnull( TypeRequest , '' ) = 'L' "
					+ " order by [idRow], r.ItemPath";

			TSRecordSet rsCur = cdf.GetRSReadFromQuery_(SQL, ApplicationCommon.Application.ConnectionString);

			if (rsCur.RecordCount > 0)
			{
				rsCur.MoveFirst();
				while (!rsCur.EOF)
				{
					htmlToReturn.Write($@"<cac:Legislation>" + Environment.NewLine);
					//'response.write "	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID( rscur.fields("UUID").value ) & "</cbc:ID>" & vbcrlf

					htmlToReturn.Write($@"	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(rsCur.Fields["UUID"]) + "</cbc:ID>" + Environment.NewLine);

					htmlToReturn.Write($@"	<cbc:Title>[Legislation title]</cbc:Title>" + Environment.NewLine);

					htmlToReturn.Write($@"	<cbc:Description>" + xmlEncode(rsCur.Fields["DescrizioneEstesa"]) + "</cbc:Description>" + Environment.NewLine);
					htmlToReturn.Write($@"	<cbc:JurisdictionLevel>EU</cbc:JurisdictionLevel>" + Environment.NewLine);
					htmlToReturn.Write($@"	<cbc:Article>[Article, e.g. Article 2.I.a]</cbc:Article>" + Environment.NewLine);
					//'response.write "	<cbc:URI>http://eur-lex.europa.eu/</cbc:URI>" & vbcrlf

					htmlToReturn.Write($@"	<cac:Language>" + Environment.NewLine);
					htmlToReturn.Write($@"		<cbc:LocaleCode listID=""LanguageCodeEU"" listAgencyName=""EU-COM-GROW"" listVersionID=""02.00.00"">EN</cbc:LocaleCode>" + Environment.NewLine);
					htmlToReturn.Write($@"	</cac:Language>" + Environment.NewLine);
					htmlToReturn.Write($@"</cac:Legislation>" + Environment.NewLine);

					rsCur.MoveNext();
				}


			}

		}

		//'-- '{ADDITIONAL_DESCRIPTION_LINE}' then 'A'--cbc:Description 
		public static void DrawAdditionalDescription(object idModulo, EprocResponse htmlToReturn)
		{

			string SQL;
			TSRecordSet rsCur;

			SQL = "select  isnull( DescrizioneEstesa , '' ) as DescrizioneEstesa,  UUID  "
					+ " from CTL_DOC m with(nolock) "
					+ "		inner join DOCUMENT_REQUEST_GROUP r with(nolock) on m.id = r.idHeader "
					+ " where   m.id = " + idModulo + " and  isnull( TypeRequest , '' ) = 'A' "
					+ " order by [idRow], r.ItemPath";

			rsCur = objDB_MTR.GetRSReadFromQuery_(SQL, ApplicationCommon.Application.ConnectionString);

			if (rsCur.RecordCount > 0)
			{

				rsCur.MoveFirst();
				while (!rsCur.EOF)
				{

					htmlToReturn.Write($@"		<cbc:Description>" + xmlEncode(rsCur.Fields["DescrizioneEstesa"]) + "</cbc:Description>" + Environment.NewLine);
					rsCur.MoveNext();

				}

			}

			//set rsCur = nothing

		}

		public static void DrawNationalSubCriterion(object idModulo, int IDDOC, string KeyRiga, int bRequest, int bloccaSottoCriteri, EprocResponse htmlToReturn, ref Dictionary<object, object> g_iterazioni, ref Dictionary<object, object> g_col, ref Dictionary<object, object> g_uuid, ref string listaResponseEvidence, ref object cfEnteMitt, HttpResponse httpResponse)
		{
			TSRecordSet rsSubCriteria;

			if (bloccaSottoCriteri == 0)
			{

				rsSubCriteria = objDB_MTR.GetRSReadFromQuery_("select id , Versione from CTL_DOC with(nolock) where tipodoc = 'TEMPLATE_REQUEST_GROUP' and versione <> '00' and deleted = 0 and linkeddoc = " + idModulo, ApplicationCommon.Application.ConnectionString);
				//'--	i sotto criteri zero li gestiamo in un metodo specifico
				//'set rsSubCriteria = objDB_MTR.GetRSReadFromQuery( cstr( "select id , Versione from CTL_DOC with(nolock) where tipodoc = 'TEMPLATE_REQUEST_GROUP' and deleted = 0 and linkeddoc = " & idModulo)  , Application("ConnectionString"))					

				if (rsSubCriteria.RecordCount > 0)
				{
					rsSubCriteria.MoveFirst();

					while (!rsSubCriteria.EOF)
					{
						if (bRequest == 1)
						{
							GetXMLModuloRequestVer2(rsSubCriteria.Fields["id"], IDDOC, KeyRiga + "_" + rsSubCriteria.Fields["Versione"], "Sub", htmlToReturn, ref listaResponseEvidence, ref g_iterazioni, ref g_col, ref g_uuid, ref bloccaSottoCriteri, IDDOC, ref cfEnteMitt, httpResponse);
						}
						else
						{
							GetXMLModuloResponseVer2(rsSubCriteria.Fields["id"], IDDOC, KeyRiga + "_" + rsSubCriteria.Fields["Versione"], "Sub", htmlToReturn, IDDOC, ref bloccaSottoCriteri, ref g_iterazioni, ref g_col, ref g_uuid, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);
						}

						rsSubCriteria.MoveNext();
					}
				}
			}
		}

		public static string xmlEncode(dynamic str)
		{
			dynamic _out = str;

			if (!string.IsNullOrEmpty(CStr(_out)))
			{
				_out = HtmlEncode(CStr(_out));
				_out = CStr(_out).Replace("'", "&apos;");
			}

			return _out;

		}
		public static string formatDate(dynamic myDate)
		{
			string _out = "";

			if (!IsNull(myDate))
			{
				if (myDate.GetType() == typeof(DateTime))
				{
					_out = $"{DateAndTime.Year(myDate)}-{Right("0" + DateAndTime.Month(myDate), 2)}-{Right("0" + DateAndTime.Day(myDate), 2)}";
				}
				else
				{
					try
					{
						myDate = CDate(myDate);
						_out = $"{DateAndTime.Year(myDate)}-{Right("0" + DateAndTime.Month(myDate), 2)}-{Right("0" + DateAndTime.Day(myDate), 2)}";
					}
					catch
					{
						return "";
					}
				}
			}

			return _out;
		}

		public static string formatTime(dynamic myDate)
		{
			string _out = "";

			if (IsNull(myDate))
			{
				if (myDate.GetType() == typeof(DateTime))
				{
					_out = $"{Right("0" + DateAndTime.Hour(myDate), 2)}:{Right("0" + DateAndTime.Minute(myDate), 2)}:{Right("0" + DateAndTime.Second(myDate), 2)}";
				}
				else
				{
					try
					{
						myDate = CDate(myDate);
						_out = $"{Right("0" + DateAndTime.Hour(myDate), 2)}:{Right("0" + DateAndTime.Minute(myDate), 2)}:{Right("0" + DateAndTime.Second(myDate), 2)}";
					}
					catch
					{
						return "";
					}
				}
			}

			return _out;
		}

		public static void addOptionalTag(dynamic value, string tag, EprocResponse htmlToReturn)
		{
			if (!string.IsNullOrEmpty(CStr(value)))
			{
				htmlToReturn.Write("<" + tag + ">" + xmlEncode(CStr(value)) + "</" + tag + ">" + Environment.NewLine);
			}
		}

		//'-- Funzione specifica per ogni pagina di template
		public static void drawModuleTemplate(int IDDOC, int bRequest, object idTemplate, EprocResponse htmlToReturn, ref string listaResponseEvidence, ref Dictionary<object, object> g_iterazioni, ref Dictionary<object, object> g_col, ref Dictionary<object, object> g_uuid, ref int bloccaSottoCriteri, ref object cfEnteMitt, HttpResponse httpResponse)
		{     //'-- idDoc +  1 se siamo su una request, 0 se siamo su una response
			//var COMANDO
			//var Modulo;
			//var Gruppo;
			//var Indice;
			//var modello;
			string SqlFilter;

			//'--IDDOC = g_ID_DOC

			SqlFilter = "";

			//'on error resume next

			//'-- Recupero tutte le parti del template ordinate
			TSRecordSet rs = objDB_MTR.GetRSReadFromQuery_("select * from TEMPLATE_REQUEST_PARTS where REQUEST_PART = 'MODULO' and idTemplate = " + idTemplate + SqlFilter + " order by row ", ApplicationCommon.Application.ConnectionString);

			//'-- ciclo su tutti i criteri presenti nel template
			if (rs.RecordCount > 0)
			{
				rs.MoveFirst();
				//'modello =  rs.fields("Modello").value
				//'response.write modello & vbcrlf

				while (!rs.EOF)
				{
					var REQUEST_PART = rs.Fields["REQUEST_PART"];
					var Descrizione = rs.Fields["Descrizione"];
					var TEMPLATE_REQUEST_GROUP = rs.Fields["TEMPLATE_REQUEST_GROUP"];
					var KeyRiga = rs.Fields["KeyRiga"];
					var idModulo = rs.Fields["idModulo"];
					var Editabile = rs.Fields["Editabile"];

					if (CStr(REQUEST_PART) == "Modulo")
					{
						if (bRequest == 1)
						{
							GetXMLModuloRequestVer2(idModulo, IDDOC, CStr(KeyRiga), "", htmlToReturn, ref listaResponseEvidence, ref g_iterazioni, ref g_col, ref g_uuid, ref bloccaSottoCriteri, IDDOC, ref cfEnteMitt, httpResponse);
						}
						else
						{
							GetXMLModuloResponseVer2(idModulo, IDDOC, CStr(KeyRiga), "", htmlToReturn, IDDOC, ref bloccaSottoCriteri, ref g_iterazioni, ref g_col, ref g_uuid, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);
						}

						//'-- aggiunge il disegno dei sub criterion nazionali
						//'--DrawNationalSubCriterion idModulo , IDDOC  ,  InCaricoA  , KeyRiga
					}

					rs.MoveNext();
				}
			}
		}

		public static void GetXMLModuloResponseVer2(object idModulo, int idDocInUse, string KeyModulo, string TipoModulo, EprocResponse htmlToReturn, int g_ID_DOC, ref int bloccaSottoCriteri, ref Dictionary<object, object> g_iterazioni, ref Dictionary<object, object> g_col, ref Dictionary<object, object> g_uuid, ref string listaResponseEvidence, ref object cfEnteMitt, HttpResponse httpResponse)
		{
			int[] VettoreIterazioni = new int[100];

			TSRecordSet rsSubCriteria;

			if (string.IsNullOrEmpty(CStr(idModulo)))
			{
				return;
			}

			//'-- faccio una select per evitare di entrare in quei criteri di tipo "SYSTEM" ( cioè quelli applicativi che non devono finire nell'xml )
			TSRecordSet rsMod = objDB_MTR.GetRSReadFromQuery_("select id from CTL_DOC m with(nolock) where isnull(m.StrutturaAziendale,'') <> 'SYSTEM' and  m.id = " + idModulo, ApplicationCommon.Application.ConnectionString);

			if (rsMod.RecordCount == 0)
			{
				return;
			}

			//'-----------------------------------------------------------------------------------------
			//'-- Prendo tutte le richieste in carico all'OE(dovrebbero essere solo le QUESTION ) ----
			//'-----------------------------------------------------------------------------------------
			string SQL = "select isnull( ItemPath , '' ) as ItemPath , isnull( RG_FLD_TYPE , '' ) as RG_FLD_TYPE , isnull( TypeRequest , '' ) as TypeRequest, isnull( DescrizioneEstesa , '' ) as DescrizioneEstesa, isnull( Related , '' ) as Related , isnull( ItemLevel , '' ) as ItemLevel , "
					+ " dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) as GUID , "
					+ " r.UUID  , "
					+ @" isnull( Iterabile , '' ) as Iterabile , replace( isnull( r.Note , '' ) , '""' , '''' ) as ToolTip , "
					+ " isnull( Obbligatorio , '' ) as Obbligatorio , "
					+ "  dz.DZT_Type,  "
					+ "  dz.DZT_DM_ID,  "
					+ "  dz.DZT_DM_ID_Um, 0 as   DZT_Len,  dz.DZT_Dec, "
					+ "  dz.DZT_Format, "
					+ "  dz.DZT_Help, dz.DZT_Multivalue , r.InCaricoA , NEWID() AS guid_on_fly "
					+ " from CTL_DOC m with(nolock) "
					+ "		inner join DOCUMENT_REQUEST_GROUP r with(nolock) on m.id = r.idHeader "
					+ " 	inner join LIB_Dictionary dz with(nolock) on dz.DZT_Name = r.RG_FLD_TYPE "
					+ " where m.id = " + idModulo + " and isnull( TypeRequest , '' ) <> 'L'"
					+ " order by [idRow], r.ItemPath";

			//'response.write SQL & vbcrlf
			//'response.end
			//'exit function

			TSRecordSet rsCur = objDB_MTR.GetRSReadFromQuery_(SQL, ApplicationCommon.Application.ConnectionString);

			if (TipoModulo.ToUpper() != "SUB")
			{
				DrawNationalSubCriterion(idModulo, g_ID_DOC, KeyModulo, 0, bloccaSottoCriteri, htmlToReturn, ref g_iterazioni, ref g_col, ref g_uuid, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);

			}

			KeyModulo = KeyModulo.ToUpper().Replace(".", "_");

			if (rsCur.RecordCount > 0)
			{
				int NewCurPosition;
				int CurPosition;

				rsCur.MoveFirst();

				CurPosition = rsCur.position;

				NewCurPosition = CurPosition - 1;

				while (!rsCur.EOF && NewCurPosition != CurPosition)
				{
					//'if rsCur.fields("ItemLevel").value = "1" then 	

					GetXMLModuloResponse(rsCur, 1, VettoreIterazioni, KeyModulo, htmlToReturn, ref g_iterazioni, ref g_col, ref g_uuid, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);

					NewCurPosition = rsCur.position;
					//'end if

					//'rsCur.movenext
				}
			}
		}

		public static void GetXMLModuloResponse(TSRecordSet rsCur, int Livello, int[] VettoreIterazioni, string KeyModulo, EprocResponse htmlToReturn, ref Dictionary<object, object> g_iterazioni, ref Dictionary<object, object> g_col, ref Dictionary<object, object> g_uuid, ref string listaResponseEvidence, ref object cfEnteMitt, HttpResponse httpResponse)
		{
			//'// CONTROLLO PARACADUTE
			if (Livello > 50)
			{
				htmlToReturn.Write($@"------- SUPERAMENTO LIMITE DI PROFONDITA DI 100 ---");
				throw new ResponseEndException(htmlToReturn.Out(), httpResponse, "------- SUPERAMENTO LIMITE DI PROFONDITA DI 100 ---");
			}

			//'-- conservo la posizione dell'elemento ch devo disegnare per riposizionarmi
			int CurPosition = rsCur.position;

			object guid_on_fly = rsCur.Fields["guid_on_fly"];
			object RG_FLD_TYPE = rsCur.Fields["RG_FLD_TYPE"];
			object GUID = rsCur.Fields["GUID"];
			object Iterabile = rsCur.Fields["Iterabile"];
			object UUID = rsCur.Fields["UUID"];
			object TypeRequest = rsCur.Fields["TypeRequest"];
			object ItemLevel = rsCur.Fields["ItemLevel"];

			int NRow = 1;
			//'Livello = 1

			//'-- recupero il numero di occorrenze del livello da disegnare nel caso sia iterabile
			if (CStr(Iterabile) == "1")
			{
				//'-- prendo il nome del campo
				string FieldStart = GetNameFieldIterato(CStr(GUID), VettoreIterazioni, "B");

				if (g_iterazioni.ContainsKey(KeyModulo + "@@@" + FieldStart))
				{
					NRow = CInt(g_iterazioni[KeyModulo + "@@@" + FieldStart]);
				}
			}

			//'-- ciclo sul numero di occorrenze
			for (int ix = 1; ix <= NRow; ix++)
			{ // to NRow
				//'-- recupero la posizione iniziale
				if (ix > 1)
				{
					rsCur.position = CurPosition;
				}

				//'-- identifico l'iesimo elemento
				if (CStr(Iterabile) == "1")
				{
					VettoreIterazioni[Livello] = ix;
				}
				else
				{
					VettoreIterazioni[Livello] = 0;
				}

				string CurField = GetNameFieldIterato(CStr(GUID), VettoreIterazioni, "");

				if (CStr(TypeRequest) == "M")
				{ //'--- {requirement}
					rsCur.MoveNext();
				}

				//'-- lavoro l'item sul quale mi trovo solo se è una question ( Implicitamente quindi in carico all'O.E. )
				if (CStr(TypeRequest) == "R")
				{ //'--- {QUESTION}
					RG_FLD_TYPE = CStr(RG_FLD_TYPE).ToUpper().Trim();
					string chiaveUUID;

					if (CStr(RG_FLD_TYPE) == "PERIOD")
					{
						//'-- SE E' UNA QUESTION DI TIPO PERIOD PRENDO L'UUID DAL CAMPO DI DATA INIZIO
						chiaveUUID = "MOD_" + KeyModulo + "_FLD_I_" + CurField;

					}
					else if (CStr(RG_FLD_TYPE) == "EVIDENCE_IDENTIFIER")
					{
						chiaveUUID = "MOD_" + KeyModulo + "_FLD_URL_" + CurField;
					}
					else
					{
						chiaveUUID = "MOD_" + KeyModulo + "_FLD_" + CurField;
					}

					object uuid = null;
					if (g_uuid.ContainsKey(chiaveUUID))
					{
						uuid = g_uuid[chiaveUUID];
					}
					string value = string.Empty;
					if (g_col.ContainsKey(chiaveUUID))
					{
						value = CStr(g_col[chiaveUUID]);
					}
					//'value = g_col( "MOD_" &  KeyModulo &  "_FLD_"  &  CurField )

					//'-- SE NON HO UNA RISPOSTA NON DEVO INSERIRE IL BLOCCO XML TENDERINGCRITERIONRESPONSE
					if (!string.IsNullOrEmpty(value))
					{
						//'-- se mi trovo i ### nel value vuol dire che sono su un multivalue. rimuovo i ### a sinistra e a destra per non avere valori vuoti splittando
						if (Strings.InStr(value, "###") > 0 && (value.Length) >= 6)
						{
							value = Strings.Right(value, (value.Length) - 3); //'- tolgo i cancelletti a sinistra
							value = Strings.Left(value, (value.Length) - 3);  //'- tolgo i cancelletti a destra
						}

						string[] vetMultiValue = Strings.Split(value, "###");

						int i = 0;
						int maxIndex = vetMultiValue.Length - 1;

						if (maxIndex == -1)
						{
							maxIndex = 0;
						}

						htmlToReturn.Write($@"<!-- " + chiaveUUID + "-->" + Environment.NewLine);
						htmlToReturn.Write($@"<!-- " + RG_FLD_TYPE + "-->" + Environment.NewLine);
						htmlToReturn.Write($@"<cac:TenderingCriterionResponse>" + Environment.NewLine);

						//'response.write "	<cbc:ID schemeID=""ISO/IEC 9834-8:2008 - 4UUID"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID(guid_on_fly) & "</cbc:ID>" & vbcrlf
						//'response.write "	<cbc:ValidatedCriterionPropertyID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID(UUID) & "</cbc:ValidatedCriterionPropertyID>" & vbcrlf

						htmlToReturn.Write($@"	<cbc:ID schemeID=""ISO/IEC 9834-8:2008 - 4UUID"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(guid_on_fly) + "</cbc:ID>" + Environment.NewLine);
						htmlToReturn.Write($@"	<cbc:ValidatedCriterionPropertyID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(UUID) + "</cbc:ValidatedCriterionPropertyID>" + Environment.NewLine);

						do
						{
							string singleValue;
							if (!string.IsNullOrEmpty(value))
							{
								singleValue = vetMultiValue[i];
							}
							else
							{
								singleValue = "";
							}

							if (CStr(RG_FLD_TYPE) != "EVIDENCE_IDENTIFIER" && CStr(RG_FLD_TYPE) != "PERIOD")
							{
								htmlToReturn.Write($@"	<cac:ResponseValue>" + Environment.NewLine);
								//'response.write "		<cbc:ID schemeID=""ISO/IEC 9834-8:2008 - 4UUID"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID(getNewGUID()) & "</cbc:ID>" & vbcrlf
								htmlToReturn.Write($@"		<cbc:ID schemeID=""ISO/IEC 9834-8:2008 - 4UUID"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(getNewGUID()) + "</cbc:ID>" + Environment.NewLine);
							}

							getXmlForFieldType("QUESTION", CStr(RG_FLD_TYPE), g_col, KeyModulo, CurField, singleValue, 0, UUID, htmlToReturn, ref listaResponseEvidence, ref cfEnteMitt);

							if (CStr(RG_FLD_TYPE) != "EVIDENCE_IDENTIFIER" && CStr(RG_FLD_TYPE) != "PERIOD")
							{
								htmlToReturn.Write($@"	</cac:ResponseValue>" + Environment.NewLine);
							}

							i = i + 1;

							//response.flush
						} 
						while (i < maxIndex);

						htmlToReturn.Write($@"</cac:TenderingCriterionResponse>" + Environment.NewLine);
					}

					rsCur.MoveNext();

					//'else
					//'	response.write "pippo(" & TypeRequest & ")"

				}  //'-- end di if TypeRequest = "R" then 

				if (CStr(TypeRequest) == "K" || CStr(TypeRequest) == "G" || CStr(TypeRequest) == "Q" || CStr(TypeRequest) == "T" || CStr(TypeRequest) == "C" || CStr(TypeRequest) == "A" || CStr(TypeRequest) == "L")
				{
					//'-- se iterabile si mette la barra
					if (CStr(Iterabile) == "1")
					{
						//'	-- riposizioni il recordset, potrebbe essersi spostato iterando 
						rsCur.position = CurPosition;
					}

					//'-- invoco il disegno dei propri figli
					rsCur.MoveNext();
					bool bContinue = true;
					while (!rsCur.EOF && bContinue)
					{
						//'-- se l'elemento è figlio lo disegna 
						if (CInt(rsCur.Fields["ItemLevel"]) == CInt(ItemLevel) + 1)
						{
							//response.flush

							//'-- invoco il metodo sul livello successivo
							GetXMLModuloResponse(rsCur, Livello + 1, VettoreIterazioni, KeyModulo, htmlToReturn, ref g_iterazioni, ref g_col, ref g_uuid, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);

							//'-- se l'elemento è mio nipote non devo disegnarlo, lo devo saltare, 衳tato disegnato dal mio figlio
						}
						else if (CInt(rsCur.Fields["ItemLevel"]) > CInt(ItemLevel) + 1)
						{
							rsCur.MoveNext();

							//'-- se l'elemento è livello superiore o uguale devo uscire
						}
						else if (CInt(rsCur.Fields["ItemLevel"]) <= CInt(ItemLevel))
						{
							bContinue = false;
						}
					}

					//'-- recupero la posizione iniziale
					//'rsCur.AbsolutePosition = CurPosition
				}
			}
		}
		public static void GetXMLModuloRequestVer2(object idModulo, int idDocInUse, string KeyModulo, string TipoModulo, EprocResponse htmlToReturn, ref string listaResponseEvidence, ref Dictionary<object, object> g_iterazioni, ref Dictionary<object, object> g_col, ref Dictionary<object, object> g_uuid, ref int bloccaSottoCriteri, int g_ID_DOC, ref object cfEnteMitt, HttpResponse httpResponse)
		{
			int[] VettoreIterazioni = new int[100];
			//dim rsSubCriteria

			if (string.IsNullOrEmpty(CStr(idModulo)))
			{
				return;
			}

			//'-- recupero il titolo da inserire come primo elemento descrittivo del gruppo di richieste
			TSRecordSet rsMod = objDB_MTR.GetRSReadFromQuery_("select  isnull( Body , '' ) as  Body ,  titolo  ,  isnull( Note , '' ) as Note , NumeroDocumento  from CTL_DOC m with(nolock) where isnull(m.StrutturaAziendale,'') <> 'SYSTEM' and  m.id = " + idModulo, ApplicationCommon.Application.ConnectionString);

			if (rsMod.RecordCount == 0)
			{
				return;
			}

			//'--response.write "select  isnull( Body , '' ) as titolo from CTL_DOC m with(nolock) where  m.id = " & idModulo

			object Titolo = rsMod.Fields["Titolo"];
			object Body = rsMod.Fields["Body"];
			object Note = rsMod.Fields["Note"];
			object UUID = rsMod.Fields["NumeroDocumento"];
			string CriterionTypeCode = CStr(rsMod.Fields["Titolo"]);

			if (CriterionTypeCode.Contains(" -", StringComparison.Ordinal))
			{
				CriterionTypeCode = Strings.Right(CriterionTypeCode, CriterionTypeCode.Length - 11);
				CriterionTypeCode = CriterionTypeCode.Replace(" -", "").Trim();
				CriterionTypeCode = CriterionTypeCode.Replace("- ", "").Trim();
			}

			//'--------------------------------------------
			//'-- recordset per tutte le richieste nel gruppo
			//'--------------------------------------------
			string SQL = "select isnull( ItemPath , '' ) as ItemPath , isnull( RG_FLD_TYPE , '' ) as RG_FLD_TYPE , isnull( TypeRequest , '' ) as TypeRequest, isnull( DescrizioneEstesa , '' ) as DescrizioneEstesa, isnull( Related , '' ) as Related , isnull( ItemLevel , '' ) as ItemLevel , "
					+ " dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) as GUID , "
					+ " r.UUID as GUID_CRITERION , "
					+ @" isnull( Iterabile , '' ) as Iterabile , replace( isnull( r.Note , '' ) , '""' , '''' ) as ToolTip , "
					+ " isnull( Obbligatorio , '' ) as Obbligatorio , "
					+ "  dz.DZT_Type,  "
					+ "  dz.DZT_DM_ID,  "
					+ "  dz.DZT_DM_ID_Um, 0 as   DZT_Len,  dz.DZT_Dec, "
					+ "  dz.DZT_Format, "
					+ "  dz.DZT_Help, dz.DZT_Multivalue , r.InCaricoA , NEWID() AS guid_on_fly "
					+ " from CTL_DOC m with(nolock) "
					+ "		inner join DOCUMENT_REQUEST_GROUP r with(nolock) on m.id = r.idHeader "
					+ " 	inner join LIB_Dictionary dz with(nolock) on dz.DZT_Name = r.RG_FLD_TYPE "
					+ " where   m.id = " + idModulo + " and isnull( TypeRequest , '' ) not in ( 'L', 'A' ) "
					+ " order by [idRow], r.ItemPath";

			//'response.write SQL
			//'response.end

			TSRecordSet rsCur = objDB_MTR.GetRSReadFromQuery_(SQL, ApplicationCommon.Application.ConnectionString);

			//'if TipoModulo <> "SUB" then 
			//'	response.write "<!-- Criterion:" & XMLencode( Body ) & " -->" & vbcrlf
			//'end if

			htmlToReturn.Write($@"<cac:" + TipoModulo + "TenderingCriterion>" + Environment.NewLine);
			//'response.write "	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID(UUID) & "</cbc:ID>" & vbcrlf
			htmlToReturn.Write($@"	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(UUID) + "</cbc:ID>" + Environment.NewLine);

			if (TipoModulo.ToUpper() != "SUB")
			{
				//'response.write "		<cbc:CriterionTypeCode listID=""CriteriaTypeCode"" listAgencyID=""EU-COM-GROW""  listVersionID=""2.1.0"">" & XMLencode( CriterionTypeCode ) & "</cbc:CriterionTypeCode>" + Environment.NewLine);
				htmlToReturn.Write($@"		<cbc:CriterionTypeCode listID=""CriteriaTypeCode"" listAgencyID=""EU-COM-GROW""  listVersionID=""2.1.1"">" + xmlEncode(CriterionTypeCode) + "</cbc:CriterionTypeCode>" + Environment.NewLine);
			}

			htmlToReturn.Write($@"		<cbc:Name>" + xmlEncode(Body) + "</cbc:Name>" + Environment.NewLine);
			htmlToReturn.Write($@"		<cbc:Description languageID=""IT"">" + xmlEncode(CStr(Note).Replace("<br>", " ")) + "</cbc:Description>" + Environment.NewLine);

			//'-- aggiunge le descrizioni aggiuntive
			DrawAdditionalDescription(idModulo, htmlToReturn);

			//'-- aggiunge il sottocriterio 0 se presente per i criteri europei ( si escludono i subcriteri )
			//'if ucase(TipoModulo) = "SUB" then
			DrawSubCriteriaZero(idModulo, bloccaSottoCriteri, htmlToReturn);
			//'end if	

			if (TipoModulo.ToUpper() != "SUB")
			{
				//'call DrawNationalSubCriterion ( idModulo ,IDDOC  ,  KeyRiga)
				DrawNationalSubCriterion(idModulo, g_ID_DOC, KeyModulo, 1, bloccaSottoCriteri, htmlToReturn, ref g_iterazioni, ref g_col, ref g_uuid, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);
			}

			//'-- aggiunge le legislation
			DrawLegislation(idModulo, htmlToReturn);

			if (rsCur.RecordCount > 0)
			{
				int NewCurPosition;
				int CurPosition;

				rsCur.MoveFirst();
				CurPosition = rsCur.position;
				NewCurPosition = CurPosition - 1;

				while (!rsCur.EOF && NewCurPosition != CurPosition)
				{
					//'if rsCur.fields("ItemLevel").value = "1" then 

					KeyModulo = KeyModulo.ToUpper().Replace(".", "_");

					GetXmlModulo(rsCur, 1, VettoreIterazioni, KeyModulo, htmlToReturn, ref bloccaSottoCriteri, ref g_iterazioni, ref g_uuid, ref g_col, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);
					NewCurPosition = rsCur.position;

					//'end if

					//'rsCur.movenext
				}
			}

			htmlToReturn.Write($@"</cac:" + TipoModulo + "TenderingCriterion>" + Environment.NewLine);

			//response.flush
		}

		//'-- funzione ricorsiva che disegna tutte gli elementi del modulo partendo dal livello indicato
		public static void GetXmlModulo(
			TSRecordSet rsCur,
			int Livello,
			int[] VettoreIterazioni,
			string KeyModulo,
			EprocResponse htmlToReturn,
			ref int bloccaSottoCriteri,
			ref Dictionary<object, object> g_iterazioni,
			ref Dictionary<object, object> g_uuid,
			ref Dictionary<object, object> g_col,
			ref string listaResponseEvidence,
			ref object cfEnteMitt,
			HttpResponse httpResponse
		)
		{
			//'// CONTROLLO PARACADUTE
			if (Livello > 50)
			{
				//response.write "------- SUPERAMENTO LIMITE DI PROFONDITA DI 50 ---"
				//response.end
				htmlToReturn.Write($@"------- SUPERAMENTO LIMITE DI PROFONDITA DI 50 ---");
				throw new ResponseEndException(htmlToReturn.Out(), httpResponse, "------ - SUPERAMENTO LIMITE DI PROFONDITA DI 50-- - ");
			}

			//var FETCHSTATUS ;//'int
			//var Html ;//'as nvarchar(max)
			//var Titolo ;//'as nvarchar(max)
			//var DescrizioneGruppo ;//'as nvarchar(max)
			object ToolTip;//'nvarchar(max)
			string CurField;//
			//var PrevItemPath  ;//'varchar(500) 
			object GUID;//'varchar(500) 
			object ItemPath;//'varchar(500) , 
			object RG_FLD_TYPE;//'varchar(500), 
			object TypeRequest;//'varchar(20) , 
			object DescrizioneEstesa;//'nvarchar(max) , 
			object Related;//'varchar ( 500)
			object ItemLevel;//'int
							 //var PrevItemLevel ;//'int
							 //var StartItemLevel ;//'int
							 //var NumColGroup ;//'int
							 //var NumCol ;//'int
							 //var PrevGUID ;//'varchar(500) 
			int NRow;//'int
			object Iterabile;//'INT
							 //var CurTypeRequest ;//'varchar(20)
							 //var ItemPathIterato  ;//'varchar(500)
			object Obbligatorio;//'int
								//var InCaricoALoc ;//'varchar(100)
			int CurPosition;//
			bool bContinue;//
			string FieldStart;//

			CurField = "";

			//'-- conservo la posizione dell'elemento che devo disegnare per riposizionarmi

			CurPosition = rsCur.position;

			ItemPath = rsCur.Fields["ItemPath"];
			RG_FLD_TYPE = rsCur.Fields["RG_FLD_TYPE"];
			TypeRequest = rsCur.Fields["TypeRequest"];
			DescrizioneEstesa = rsCur.Fields["DescrizioneEstesa"];
			Related = rsCur.Fields["Related"];
			ItemLevel = rsCur.Fields["ItemLevel"];
			GUID = rsCur.Fields["GUID"];
			object guid_on_fly = rsCur.Fields["guid_on_fly"];

			object GUID_CRITERION = rsCur.Fields["GUID_CRITERION"];

			if ((CStr(GUID_CRITERION)).Trim() == "")
			{
				GUID_CRITERION = GUID;
			}

			//'-- se richiesto NO NATIONAL
			if (bloccaSottoCriteri == 1)
			{
				//'--- SALTIAMO TUTTI I NODI DI UN ELEMENTO IT-
				if (Strings.Left(CStr(GUID_CRITERION), 3).ToUpper() == "IT-")
				{
					rsCur.MoveNext();

					do
					{
						//'-- Continuiamo a scorrere fintanto che ci troviamo su un elemento con livello maggiore del nodo dal quale siamo partiti
						if (CInt(rsCur.Fields["ItemLevel"]) > CInt(ItemLevel))
						{
							rsCur.MoveNext();
						}
						else
						{
							break;
						}

					} while (!rsCur.EOF);

					return;
				}
			}

			//'-- PEZZA DA TOGLIERE QUANDO GENEREREMO CORRETTAMENTE GLI UUID PER TUTTI I PEZZI
			if (CStr(GUID_CRITERION).Trim().Length < 36)
			{
				GUID_CRITERION = guid_on_fly;
			}

			Iterabile = rsCur.Fields["Iterabile"];
			ToolTip = rsCur.Fields["ToolTip"];
			Obbligatorio = rsCur.Fields["Obbligatorio"];
			object DZT_Type = rsCur.Fields["DZT_Type"];
			object DZT_DM_ID = rsCur.Fields["DZT_DM_ID"];
			object DZT_DM_ID_Um = rsCur.Fields["DZT_DM_ID_Um"];
			object DZT_Dec = rsCur.Fields["DZT_Dec"];
			object DZT_Len = rsCur.Fields["DZT_Len"];
			object DZT_Format = rsCur.Fields["DZT_Format"];
			object DZT_Help = rsCur.Fields["DZT_Help"];
			object DZT_InCaricoA = rsCur.Fields["InCaricoA"];

			//'-- di base ogni elemento è presente una volta sola
			NRow = 1;

			//'-- verifico se è iterabile
			Iterabile = rsCur.Fields["Iterabile"];

			//'-- recupero il numero di occorrenze del livello da disegnare nel caso sia iterabile
			if (CStr(Iterabile) == "1")
			{
				//'-- prendo il nome del campo
				FieldStart = GetNameFieldIterato(CStr(GUID), VettoreIterazioni, "B");

				if (g_iterazioni.ContainsKey(KeyModulo + "@@@" + FieldStart))
				{
					NRow = CInt(g_iterazioni[KeyModulo + "@@@" + FieldStart]);
				}
			}

			//'GROUP_FULFILLED.ON_FALSE
			//'GROUP_FULFILLED.ON_TRUE

			//'•	ON* - significa che il gruppo DEVE essere sempre processato per verificare se l'OE deve rispondere a una domanda specifica, introdotta come Proprietà del gruppo;
			//'•	ONTRUE - significa che il gruppo DEVE essere elaborato solo se il gruppo di proprietà “padre” contiene una singola proprietà, di tipo DOMANDA, il cui valore atteso è un INDICATOR e la risposta dell'OE è "true";
			//'•	ONFALSE - significa che il gruppo DEVE essere elaborato solo se il gruppo di proprietà “padre” contiene una singola proprietà, di tipo DOMANDA, il cui valore atteso è un INDICATOR e la risposta dell'OE è "false".

			//'//'-- IL VALIDATORE EUROPEO ANDAVA IN ERRORE PER 2 SOTTO GRUPPI CON UN ON* MENTRE VOLEVA STRINGA VUOTA
			if (CStr(Related).Trim() == "")
			{
				Related = "";
			}
			else
			{
				if (CStr(Related).ToUpper().Trim() == "GROUP_FULFILLED.ON_TRUE")
				{
					Related = "ONTRUE";
				}
				else if (CStr(Related).ToUpper().Trim() == "GROUP_FULFILLED.ON_FALSE")
				{
					Related = "ONFALSE";
				}
				else
				{
					Related = "ON*";
				}
			}

			//'-- bypass temporaneo per non far andare in errore il validatore europeo
			//'if trim(ucase(GUID_CRITERION)) = "9B3A04FF-E36D-4D4F-B47C-82AD402B9B02" or trim(ucase(GUID_CRITERION)) = "5FE93344-ED91-4F97-BCAB-B6720A131798" ) {
			//'	Related = ""
			//'}

			//'-- ciclo sul numero di occorrenze
			for (int ix = 1; ix <= NRow; ix++)
			{// to NRow
				//'-- recupero la posizione iniziale
				if (ix > 1)
				{
					rsCur.position = CurPosition;
				}

				//'-- identifico l'iesimo elemento
				if (CStr(Iterabile) == "1")
				{
					VettoreIterazioni[Livello] = ix;
				}
				else
				{
					VettoreIterazioni[Livello] = 0;
				}

				CurField = GetNameFieldIterato(CStr(GUID), VettoreIterazioni, "");

				//'						when @Element = '{QUESTION_GROUP' then 'K' --'G'		-- cac:TenderingCriterionPropertyGroup
				//'						when @Element = '{QUESTION_SUBGROUP' then 'G'			-- cac:SubsidiaryTenderingCriterionPropertyGroup
				//'						when @Element = '{QUESTION}' then 'R'					-- cac:TenderingCriterionProperty
				//'
				//'						when @Element = '{REQUIREMENT_GROUP' then 'T' --'Q'		-- cac:TenderingCriterionPropertyGroup
				//'						when @Element = '{REQUIREMENT_SUBGROUP' then 'Q'		-- cac:SubsidiaryTenderingCriterionPropertyGroup
				//'						when @Element = '{REQUIREMENT}' then 'M'				-- cac:TenderingCriterionProperty
				//'
				//'						when @Element = '{CAPTION}' then 'C'					-- cac:TenderingCriterionProperty
				//'						when @Element = '{LEGISLATION}' then 'L'				-- cac:Legislation
				//'						when @Element = '{ADDITIONAL_DESCRIPTION_LINE}' then 'A'--cbc:Description 			

				//'-- REQUIREMENT_GROUP e QUESTION_GROUP  --> cac: TenderingCriterionPropertyGroup

				if (CStr(TypeRequest) == "T" || CStr(TypeRequest) == "K" || CStr(TypeRequest) == "Q" || CStr(TypeRequest) == "G")
				{
					string prefixTenderingCriterion = "";

					//'REQUIREMENT_SUB_GROUP E QUESTION_SUB_GROUP	--> SubsidiaryTenderingCriterionPropertyGroup

					if (CStr(TypeRequest) == "Q" || CStr(TypeRequest) == "G")
					{
						prefixTenderingCriterion = "Subsidiary";
					}

					//'-- APRO IL BLOCCO, DOVREI CHIUDERE FUORI IN USCITA RICORSIONE

					htmlToReturn.Write($@"<cac:" + prefixTenderingCriterion + "TenderingCriterionPropertyGroup>" + Environment.NewLine);

					//'response.write "	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID( GUID_CRITERION ) & "</cbc:ID>" & vbcrlf
					//'response.write "		<cbc:PropertyGroupTypeCode listID=""PropertyGroupType"" listAgencyID=""EU-COM-GROW""  listVersionID=""2.1.0"">" & XMLencode( Related ) & "</cbc:PropertyGroupTypeCode>" & vbcrlf

					htmlToReturn.Write($@"	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(GUID_CRITERION) + "</cbc:ID>" + Environment.NewLine);
					htmlToReturn.Write($@"		<cbc:PropertyGroupTypeCode listID=""PropertyGroupType"" listAgencyID=""EU-COM-GROW""  listVersionID=""2.1.1"">" + xmlEncode(Related) + "</cbc:PropertyGroupTypeCode>" + Environment.NewLine);
				}

				//'-- '{ ADDITIONAL_DESCRIPTION_LINE}
				//' ) { 'A'

				//'if TypeRequest = "A" ) {
				//'	response.write "<cbc:Description>" & XMLEncode( DescrizioneEstesa ) & "</cbc:Description>" & vbcrlf
				//'}		

				RG_FLD_TYPE = CStr(RG_FLD_TYPE).ToUpper();

				string chiaveUUID;

				if (CStr(RG_FLD_TYPE) == "PERIOD")
				{
					//'-- SE E' UNA QUESTION DI TIPO PERIOD PRENDO L'UUID DAL CAMPO DI DATA INIZIO

					chiaveUUID = "MOD_" + KeyModulo + "_FLD_I_" + CurField;
				}
				else if (CStr(RG_FLD_TYPE) == "EVIDENCE_IDENTIFIER")
				{
					chiaveUUID = "MOD_" + KeyModulo + "_FLD_URL_" + CurField;
				}
				else
				{
					chiaveUUID = "MOD_" + KeyModulo + "_FLD_" + CurField;
				}

				object uuid = null;
				if (g_uuid.ContainsKey(chiaveUUID))
				{
					uuid = g_uuid[chiaveUUID];
				}

				//'value = g_col( "MOD_" &  KeyModulo &  "_FLD_"  &  CurField )

				object value = null;
				if (g_col.ContainsKey(chiaveUUID))
				{
					value = g_col[chiaveUUID];
				}

				//'-- se mi trovo i ### nel value vuol dire che sono su un multivalue. rimuovo i ### a sinistra e a destra per non avere valori vuoti splittando

				if (CStr(value).Length >= 6 && Strings.InStr(CStr(value), "###") > 0)
				{
					value = Strings.Right(CStr(value), (CStr(value).Length) - 3); //'- tolgo i cancelletti a sinistra

					value = Strings.Left(CStr(value), (CStr(value).Length) - 3);  //'- tolgo i cancelletti a destra
				}

				htmlToReturn.Write($@"<!-- " + chiaveUUID + " -->" + Environment.NewLine);

				//'uuid = GUID_CRITERION

				//'--------------------------------------------------------------------------------------------------------------
				//'-- OGNI QUESTION E REQUIREMENT AVRA' UN PROPRIO UUID UNIVOCO PER POTER ESSERE REFERENZIATO DALLA RESPONSE ----
				//'--------------------------------------------------------------------------------------------------------------

				string[] vetMultiValue = Strings.Split(CStr(value), "###");

				//'response.write "<!-- '" & cstr(value) & "' -->" & vbcrlf

				int i = 0;

				int maxIndex = (vetMultiValue.Length - 1);

				if (maxIndex == -1)
				{
					maxIndex = 0;
				}

				//'for i = 0 to Ubound(vetMultiValue)

				do
				{
					string singleValue;
					if (!string.IsNullOrEmpty(CStr(value)))
					{
						singleValue = vetMultiValue[i];
					}
					else
					{
						singleValue = "";
					}

					//'response.write "<!-- '" & cstr(value) & "'xx -->" & vbcrlf

					//'response.write "<!-- '" & cstr(singleValue) & "' -->" & vbcrlf

					//'-- '{ QUESTION }' ) { 'R'

					if (CStr(TypeRequest) == "R")
					{
						htmlToReturn.Write($@"<cac:TenderingCriterionProperty>" + Environment.NewLine);

						//'response.write "	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID( uuid ) & "</cbc:ID>" & vbcrlf

						htmlToReturn.Write($@"	<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(uuid) + "</cbc:ID>" + Environment.NewLine);

						htmlToReturn.Write($@"	<cbc:Description languageID=""IT"">" + xmlEncode(DescrizioneEstesa) + "</cbc:Description>" + Environment.NewLine);

						//'response.write "	<cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">QUESTION</cbc:TypeCode>" & vbcrlf

						htmlToReturn.Write($@"	<cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">QUESTION</cbc:TypeCode>" + Environment.NewLine);

						//'-- ValueDataTypeCode : TIPO DI RISPOSTA ATTESA DALLA STAZIONE APPALTANTE NEL CASO DI PROPRIETÀ DI TIPO QUESTION

						//'-- per le QUESTION , 'ValueDataTypeCode' non può essere NONE

						getXmlForFieldType("QUESTION", CStr(RG_FLD_TYPE), g_col, KeyModulo, CurField, singleValue, 1, uuid, htmlToReturn, ref listaResponseEvidence, ref cfEnteMitt);

						htmlToReturn.Write($@"</cac:TenderingCriterionProperty>" + Environment.NewLine);
					}

					//'/  '{ REQUIREMENT}' ) { 'M'

					if (CStr(TypeRequest) == "M")
					{
						htmlToReturn.Write($@"<cac:TenderingCriterionProperty>" + Environment.NewLine);

						//'response.write "		<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID( uuid ) & "</cbc:ID>" & vbcrlf

						htmlToReturn.Write($@"		<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(uuid) + "</cbc:ID>" + Environment.NewLine);


						htmlToReturn.Write($@"		<cbc:Description languageID=""IT"">" + xmlEncode(DescrizioneEstesa) + "</cbc:Description>" + Environment.NewLine);

						//'response.write "		<cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">REQUIREMENT</cbc:TypeCode>" & vbcrlf

						htmlToReturn.Write($@"		<cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">REQUIREMENT</cbc:TypeCode>" + Environment.NewLine);

						getXmlForFieldType("REQUIREMENT", CStr(RG_FLD_TYPE), g_col, KeyModulo, CurField, singleValue, 1, uuid, htmlToReturn, ref listaResponseEvidence, ref cfEnteMitt);

						htmlToReturn.Write($@"</cac:TenderingCriterionProperty>" + Environment.NewLine);
					}

					i = i + 1;

				} while (i < maxIndex);

				//'-- '{ CAPTION}' ) { 'C'

				if (CStr(TypeRequest) == "C")
				{
					htmlToReturn.Write($@"<cac:TenderingCriterionProperty>" + Environment.NewLine);

					//'response.write "		<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.0"">" & normalizeUUID( GUID_CRITERION ) & "</cbc:ID>" & vbcrlf

					htmlToReturn.Write($@"		<cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(GUID_CRITERION) + "</cbc:ID>" + Environment.NewLine);


					//'response.write "		<cbc:Description>" & XMLEncode( g_col( "MOD_" &  KeyModulo &  "_FLD_I_"  &  CurField  ) ) & "</cbc:Description>" & vbcrlf

					htmlToReturn.Write($@"		<cbc:Description languageID=""IT"">" + xmlEncode(CStr(DescrizioneEstesa).Trim()) + "</cbc:Description>" + Environment.NewLine);

					//'response.write "		<cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CAPTION</cbc:TypeCode>" & vbcrlf

					htmlToReturn.Write($@"		<cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CAPTION</cbc:TypeCode>" + Environment.NewLine);

					//'--	ValueDataTypeCode fisso a NONE per gli element type  CAPTION

					//'response.write "		<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">NONE</cbc:ValueDataTypeCode>" & vbcrlf

					htmlToReturn.Write($@"		<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">NONE</cbc:ValueDataTypeCode>" + Environment.NewLine);

					htmlToReturn.Write($@"</cac:TenderingCriterionProperty>" + Environment.NewLine);
				}

				if (CStr(TypeRequest) == "K" || CStr(TypeRequest) == "G" || CStr(TypeRequest) == "Q" || CStr(TypeRequest) == "T" || CStr(TypeRequest) == "C" || CStr(TypeRequest) == "A" || CStr(TypeRequest) == "L")
				{
					//'-- se iterabile si mette la barra

					if (CStr(Iterabile) == "1")
					{
						//'	-- riposizioni il recordset, potrebbe essersi spostato iterando 
						rsCur.position = CurPosition;
					}

					//'-- invoco il disegno dei propri figli

					rsCur.MoveNext();
					bContinue = true;

					while (!rsCur.EOF && bContinue)
					{
						//'-- se l'elemento è figlio lo disegna

						if (CInt(rsCur.Fields["ItemLevel"]) == CInt(ItemLevel) + 1)
						{
							//response.flush

							//'-- invoco il disegno dell'elemento successivo

							GetXmlModulo(rsCur, Livello + 1, VettoreIterazioni, KeyModulo, htmlToReturn, ref bloccaSottoCriteri, ref g_iterazioni, ref g_uuid, ref g_col, ref listaResponseEvidence, ref cfEnteMitt, httpResponse);

							//'-- se l'elemento è mio nipote non devo disegnarlo, lo devo saltare, 衳tato disegnato dal mio figlio
						}
						else if (CInt(rsCur.Fields["ItemLevel"]) > CInt(ItemLevel) + 1)
						{
							rsCur.MoveNext();

							//'-- se l'elemento è livello superiore o uguale devo uscire
						}
						else if (CInt(rsCur.Fields["ItemLevel"]) <= CInt(ItemLevel))
						{
							bContinue = false;
						}
						//'rsCur.movenext
					}

					if (CStr(TypeRequest) == "T" || CStr(TypeRequest) == "K" || CStr(TypeRequest) == "Q" || CStr(TypeRequest) == "G")
					{
						string prefixTenderingCriterion = "";

						//'REQUIREMENT_SUB_GROUP E QUESTION_SUB_GROUP	--> SubsidiaryTenderingCriterionPropertyGroup

						if (CStr(TypeRequest) == "Q" || CStr(TypeRequest) == "G")
						{
							prefixTenderingCriterion = "Subsidiary";
						}

						//'-- chiudo il blocco xml 

						htmlToReturn.Write($@"</cac:" + prefixTenderingCriterion + "TenderingCriterionPropertyGroup>" + Environment.NewLine);
					}

					//'-- recupero la posizione iniziale

					//'rsCur.AbsolutePosition = CurPosition
				}
				else
				{
					rsCur.MoveNext();
				}
			}
		}

		public static void getXmlForFieldType(string TipoCriterion, string RG_FLD_TYPE, Dictionary<object, object> g_col, string KeyModulo, string CurField, string valoreForzato, int bRequest, object questionIdEvidence, EprocResponse htmlToReturn, ref string listaResponseEvidence, ref object cfEnteMitt)
		{
			string value = string.Empty;
			if (string.IsNullOrEmpty(valoreForzato))
			{
				//'value = g_col( "MOD_" &  KeyModulo &  "_FLD_I_"  &  CurField  )
				if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_" + CurField))
				{
					value = CStr(g_col["MOD_" + KeyModulo + "_FLD_" + CurField]);
				}
			}
			else
			{
				value = valoreForzato;
			}

			switch (RG_FLD_TYPE)
			{
				case "AMOUNT":

					string valCurrency = string.Empty;
					if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_CUR_" + CurField))
					{
						valCurrency = CStr(g_col["MOD_" + KeyModulo + "_FLD_CUR_" + CurField]);
					}

					if (string.IsNullOrEmpty(CStr(valCurrency)))
					{
						valCurrency = "EUR";

					}


					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">AMOUNT</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">AMOUNT</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedAmount

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{


							htmlToReturn.Write($@"<cbc:ExpectedAmount currencyID=""" + xmlEncode(valCurrency) + @""">" + xmlEncode(value) + "</cbc:ExpectedAmount>");


						}


					}
					else
					{

						if (!string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ResponseAmount currencyID=""" + xmlEncode(valCurrency) + @""">" + xmlEncode(value) + "</cbc:ResponseAmount>" + Environment.NewLine);

						}


					}

					break;

				case "CODE_BOOLEAN":
				case "CODE_BOOLEAN_TYPE_REQUIREMENT":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE_BOOLEAN</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE_BOOLEAN</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- ExpectedCode non necessario in quanto il valore atteso non è gestito ??

						//'<cbc:ExpectedCode listID="BooleanGUIControlType" listAgencyID="EU-COM-GROW" listVersionID="2.1.0">RADIO_BUTTON_TRUE</cbc:ExpectedCode>


						if (!string.IsNullOrEmpty(value))
						{


							if (CStr(value) == "1" || CStr(value).ToLower() == "true" || CStr(value).ToLower() == "si")
							{

								htmlToReturn.Write($@"<cbc:ExpectedCode listID=""BooleanGUIControlType"" listAgencyID=""EU-COM-OP"" listVersionID=""1.0"">RADIO_BUTTON_TRUE</cbc:ExpectedCode>");

							}
							else
							{
								htmlToReturn.Write($@"<cbc:ExpectedCode listID=""BooleanGUIControlType"" listAgencyID=""EU-COM-OP"" listVersionID=""1.0"">RADIO_BUTTON_FALSE</cbc:ExpectedCode>");

							}


						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}



					break;

				case "CODE_COUNTRY":
				case "COUNTRY":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE_COUNTRY</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE_COUNTRY</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode>" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}
					break;

				case "CODE":
				case "CODE_TI":
				case "CODE_TS": //'-- questi non dovrebbero esistere più. non ci sono CODE generici. perchè tutti gli ExpectedCode devono avere gli attributi listID,listAgencyID,listVersionID

					//'value = getDomExtValue("CODICE_CPV", value)


					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedCode

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode>" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}


					break;

				case "CODE_CPV":
				case "CPVCODES":

					value = CStr(getDomExtValue("CODICE_CPV", value));


					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedCode

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode listID=""CPVCodes"" listAgencyID=""EU-COM-OP"" listVersionID=""20080817"">" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}



					break;

				case "CODE_EOROLETYPE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedCode

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							//'response.write "<cbc:ExpectedCode listID=""EORoleType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">" & xmlEncode(value) & "</cbc:ExpectedCode>"

							htmlToReturn.Write($@"<cbc:ExpectedCode listID=""EORoleType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}

					break;

				case "CODE_FINANCIALRATIOTYPE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedCode

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode listID=""FinancialRatioType"" listAgencyID=""BACH"" listVersionID=""1.0"">" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}


					break;

				case "CODE_BIDTYPE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedCode

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode listID=""BidType"" listAgencyID=""EU-COM-OP"" listVersionID=""1.0"">" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseCode", htmlToReturn);
						//'response.write "<cbc:ResponseCode>" & xmlEncode(value) & "</cbc:ResponseCode>" & vbcrlf


					}


					break;

				case "DATE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">DATE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">DATE</cbc:ValueDataTypeCode>" + Environment.NewLine);

						//'-- QUALE TAG 'EXPECTED' DEVO USARE ???


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseDate", htmlToReturn);
						//'response.write "<cbc:ResponseDate>" & getTecDateNoTime(value) & "</cbc:ResponseDate>" & vbcrlf


					}

					break;

				case "DESCRIPTION":
				case "TEXT":
				case "TEXTAREA":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">DESCRIPTION</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">DESCRIPTION</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedDescription

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedDescription>" + xmlEncode(value) + "</cbc:ExpectedDescription>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:Description", htmlToReturn);
						//'response.write "<cbc:Description>" & xmlEncode(value) & "</cbc:Description>" & vbcrlf


					}


					break;

				case "EVIDENCE_IDENTIFIER":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">EVIDENCE_IDENTIFIER</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">EVIDENCE_IDENTIFIER</cbc:ValueDataTypeCode>" + Environment.NewLine);


					}
					else
					{

						htmlToReturn.Write($@"<cac:EvidenceSupplied>" + Environment.NewLine);

						//'response.write "	<cbc:ID schemeAgencyID=""ISO/IEC 9834-8:2008 - 4UUID"">" & xmlEncode(value) & "</cbc:ID>" & vbcrlf


						//'-- la risposta ad una evidence come valore ID del blocco di response ( EvidenceSupplied ) ci va l'id della request - question per la quale forniamo la evidence

						htmlToReturn.Write($@"	<cbc:ID schemeAgencyID=""ISO/IEC 9834-8:2008 - 4UUID"">" + xmlEncode(questionIdEvidence) + "</cbc:ID>" + Environment.NewLine);


						htmlToReturn.Write($@"</cac:EvidenceSupplied>" + Environment.NewLine);


						object evidenceUrl = null;
						if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_URL_" + CurField))
						{
							evidenceUrl = g_col["MOD_" + KeyModulo + "_FLD_URL_" + CurField];
						}

						object evidenceReference = null;
						if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_REF_" + CurField))
						{
							evidenceReference = g_col["MOD_" + KeyModulo + "_FLD_REF_" + CurField];
						}

						object evidenceIssuer = null;
						if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_ISS_" + CurField))
						{
							evidenceIssuer = g_col["MOD_" + KeyModulo + "_FLD_ISS_" + CurField];
						}


						addEvidenceResponse(questionIdEvidence, evidenceUrl, evidenceReference, evidenceIssuer, ref listaResponseEvidence);


						//'-- URL

						//'"MOD_" &  KeyModulo &  "_FLD_URL_"  &  CurField 

						//'-- REFERENCE

						//'"MOD_" &  KeyModulo &  "_FLD_REF_"  &  CurField

						//'-- ISSUER

						//'"MOD_" &  KeyModulo &  "_FLD_ISS_"  &  CurField 



					}

					break;

				case "INDICATOR":
				case "SINO":
				case "SINOALTRO":  //'-- l'indicator è un attributo di tipo true / false
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">INDICATOR</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">INDICATOR</cbc:ValueDataTypeCode>" + Environment.NewLine);

						//'<cbc:ExpectedID schemeAgencyID="EU-COM-GROW">false</cbc:ExpectedID> ??? l'ho trovato nella request consip ma da nessun altra parte.


					}
					else
					{

						if (!string.IsNullOrEmpty(CStr(value)))
						{

							if (CStr(value) == "1" || CStr(value).ToLower() == "true" || CStr(value).ToLower() == "si")
							{

								htmlToReturn.Write($@"<cbc:ResponseIndicator>true</cbc:ResponseIndicator>" + Environment.NewLine);

							}
							else
							{
								htmlToReturn.Write($@"<cbc:ResponseIndicator>false</cbc:ResponseIndicator>" + Environment.NewLine);

							}

						}


					}



					break;

				case "WEIGHT_INDICATOR":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">WEIGHT_INDICATOR</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">WEIGHT_INDICATOR</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (!string.IsNullOrEmpty(CStr(value)))
						{

							if (CStr(value) == "1" || CStr(value).ToLower() == "true" || CStr(value).ToLower() == "si")
							{

								htmlToReturn.Write($@"<cbc:ExpectedID schemeAgencyID=""EU-COM-GROW"">true</cbc:ExpectedID>" + Environment.NewLine);

							}
							else
							{
								htmlToReturn.Write($@"<cbc:ExpectedID schemeAgencyID=""EU-COM-GROW"">false</cbc:ExpectedID>" + Environment.NewLine);

							}

						}




						//'-- non si trova una controparte di response. il WEIGHT_INDICATOR sembra essere usato solo per i requirement e non per le question


					}



					break;

				case "PERCENTAGE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">PERCENTAGE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">PERCENTAGE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{


							//'-- ci vuole un ExpectedValueNumeric ??

							htmlToReturn.Write($@"<cbc:ExpectedValueNumeric>" + xmlEncode(value) + "</cbc:ExpectedValueNumeric>");


						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseQuantity", htmlToReturn);
						//'response.write "<cbc:ResponseQuantity>" & xmlEncode(value) & "</cbc:ResponseQuantity>"


					}


					break;

				case "PERIOD":
					string Data_I = string.Empty;
					if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_I_" + CurField))
					{
						Data_I = CStr(g_col["MOD_" + KeyModulo + "_FLD_I_" + CurField]);
					}
					string Data_F = string.Empty;
					if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_F_" + CurField))
					{
						Data_F = CStr(g_col["MOD_" + KeyModulo + "_FLD_F_" + CurField]);
					}
					
					if (bRequest == 1)
					{

						//'response.write "<!-- " & "MOD_" &  KeyModulo &  "_FLD_I_"  &  CurField & " -->" & vbcrlf
						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">PERIOD</cbc:ValueDataTypeCode>" & vbcrlf
						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">PERIOD</cbc:ValueDataTypeCode>" + Environment.NewLine);

						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedDescription
						if (TipoCriterion.ToUpper() == "REQUIREMENT" && (!string.IsNullOrEmpty(Data_I) || !string.IsNullOrEmpty(Data_F)))
						{

							//'if Data_I <> "" or Data_F <> "" then

							//'-- cardinalità 0..1, dovrebbe essere obbligatorio se TipoCriterion = REQUIREMENT ? 
							htmlToReturn.Write($@"<cac:ApplicablePeriod>" + Environment.NewLine);
							htmlToReturn.Write($@"	<cbc:StartDate>" + getTecDateNoTime(Data_I) + "</cbc:StartDate>" + Environment.NewLine);
							htmlToReturn.Write($@"	<cbc:EndDate>" + getTecDateNoTime(Data_F) + "</cbc:EndDate>" + Environment.NewLine);
							htmlToReturn.Write($@"</cac:ApplicablePeriod>" + Environment.NewLine);

							//'end if

						}

					}
					else
					{

						if (!string.IsNullOrEmpty(Data_I) || !string.IsNullOrEmpty(Data_F))
						{
							htmlToReturn.Write($@"<cac:ApplicablePeriod>" + Environment.NewLine);
							addOptionalTag(getTecDateNoTime(Data_I), "cbc:StartDate", htmlToReturn);
							//'response.write "	<cbc:StartDate>" & getTecDateNoTime(Data_I) & "</cbc:StartDate>" & vbcrlf
							addOptionalTag(getTecDateNoTime(Data_F), "cbc:EndDate", htmlToReturn);
							//'response.write "	<cbc:EndDate>" & getTecDateNoTime(Data_F) & "</cbc:EndDate>" & vbcrlf
							htmlToReturn.Write($@"</cac:ApplicablePeriod>" + Environment.NewLine);
						}

					}

					break;


				case "QUANTITY_INTEGER":
				case "QUANTITY":
				case "NUMBER_I":
				case "NUMBER_F":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">" & RG_FLD_TYPE & "</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">" + RG_FLD_TYPE + "</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//'-- se siamo su un REQUIREMENT aggiungo il tag ExpectedValueNumeric

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							//'-- cardinalità 0..1, dovrebbe essere obbligatorio se TipoCriterion = REQUIREMENT ? 

							htmlToReturn.Write($@"<cbc:ExpectedValueNumeric>" + xmlEncode(value) + "</cbc:ExpectedValueNumeric>");

						}


					}
					else
					{

						addOptionalTag(value, "cbc:ResponseQuantity", htmlToReturn);
						//'response.write "<cbc:ResponseQuantity>" & xmlEncode(value) & "</cbc:ResponseQuantity>"


					}


					break;

				case "QUANTITY_YEAR":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">QUANTITY_YEAR</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">QUANTITY_YEAR</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedValueNumeric>" + xmlEncode(value) + "</cbc:ExpectedValueNumeric>");

						}


					}
					else
					{

						//'response.write "<cbc:ResponseNumeric>" & xmlEncode(value) & "</cbc:ResponseNumeric>"

						//'call addOptionalTag(value, "cbc:ResponseQuantity")

						htmlToReturn.Write($@"<cbc:ResponseQuantity unitCode=""YEAR"">" + xmlEncode(value) + "</cbc:ResponseQuantity>");

					}

					break;

				case "NONE":
					if (bRequest == 1)
					{

						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">NONE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">NONE</cbc:ValueDataTypeCode>" + Environment.NewLine);

					}


					break;

				case "IDENTIFIER":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">IDENTIFIER</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">IDENTIFIER</cbc:ValueDataTypeCode>" + Environment.NewLine);


						//''-- il value per identifier_eo devo recuperarlo così "MOD_" & KeyModulo & "_FLD_ID_" & CurField ??

						//'-- se siamo su un REQUIREMENT aggiungo il tag cbc:ExpectedID

						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							//'-- cardinalità 0..1, dovrebbe essere obbligatorio se TipoCriterion = REQUIREMENT ? 

							htmlToReturn.Write($@"<cbc:ExpectedID schemeAgencyID=""EU-COM-GROW"">" + xmlEncode(value) + "</cbc:ExpectedID>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseID schemeAgencyID=""EU-COM-GROW"">" + xmlEncode(value) + "</cbc:ResponseID>");


					}
					break;

				case "ECONOMIC_OPERATOR_IDENTIFIER":
				case "IDENTIFIER_EO":    //'-- nella risposta si mappa su cbc:ResponseID 
					if (bRequest == 1)
					{

						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">ECONOMIC_OPERATOR_IDENTIFIER</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">ECONOMIC_OPERATOR_IDENTIFIER</cbc:ValueDataTypeCode>" + Environment.NewLine);

					}
					else
					{

						string tipoIdentificatore = string.Empty;
						if (g_col.ContainsKey("MOD_" + KeyModulo + "_FLD_ID_" + CurField))
						{
							tipoIdentificatore = CStr(g_col["MOD_" + KeyModulo + "_FLD_ID_" + CurField]); //'-- dominio EOIDType
						}


						if (string.IsNullOrEmpty(tipoIdentificatore))
						{
							tipoIdentificatore = "VAT";

						}


						htmlToReturn.Write($@"<cbc:ResponseID schemeName=""" + tipoIdentificatore + @""" schemeAgencyID=""EU-COM-GROW"">" + xmlEncode(value) + "</cbc:ResponseID>");

					}



					break;

				case "LOT_IDENTIFIER":
				case "IDENTIFIER_LOT":
					if (bRequest == 1)
					{

						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">LOT_IDENTIFIER</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">LOT_IDENTIFIER</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedID schemeAgencyID=""" + cfEnteMitt + @""">" + xmlEncode(value) + "</cbc:ExpectedID>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseID schemeAgencyID=""" + cfEnteMitt + @""">" + xmlEncode(value) + "</cbc:ResponseID>");


					}



					break;

				case "URL":
					if (bRequest == 1)
					{


						//'-- il value si recupera con : "MOD_" &  KeyModulo &  "_FLD_URL_"  &  CurField ?


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">URL</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">URL</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (!string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedID schemeID=""URI"" schemeAgencyID=""EU-COM-GROW"">" + xmlEncode(value) + "</cbc:ExpectedID>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseURI>" + xmlEncode(value) + "</cbc:ResponseURI>");


					}


					break;

				case "MAXIMUM_AMOUNT":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">MAXIMUM_AMOUNT</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">MAXIMUM_AMOUNT</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:MaximumAmount>" + xmlEncode(value) + "</cbc:MaximumAmount>");

						}


					}
					else
					{

						if (!string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ResponseAmount>" + xmlEncode(value) + "</cbc:ResponseAmount>");

						}


					}
					break;

				case "MINIMUM_AMOUNT":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">MINIMUM_AMOUNT</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">MINIMUM_AMOUNT</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:MinimumAmount>" + xmlEncode(value) + "</cbc:MinimumAmount>");

						}


					}
					else
					{

						if (!string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ResponseAmount>" + xmlEncode(value) + "</cbc:ResponseAmount>");

						}


					}



					break;

				case "MAXIMUM_VALUE_NUMERIC":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">MAXIMUM_VALUE_NUMERIC</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">MAXIMUM_VALUE_NUMERIC</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:MaximumValueNumeric>" + xmlEncode(value) + "</cbc:MaximumValueNumeric>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseNumeric>" + xmlEncode(value) + "</cbc:ResponseNumeric>");


					}


					break;

				case "MINIMUM_VALUE_NUMERIC":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">MINIMUM_VALUE_NUMERIC</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">MINIMUM_VALUE_NUMERIC</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:MinimumValueNumeric>" + xmlEncode(value) + "</cbc:MinimumValueNumeric>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseNumeric>" + xmlEncode(value) + "</cbc:ResponseNumeric>");


					}


					break;

				case "TRANSLATION_TYPE_CODE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">TRANSLATION_TYPE_CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">TRANSLATION_TYPE_CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode>" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseCode>" + xmlEncode(value) + "</cbc:ResponseCode>");


					}


					break;

				case "CERTIFICATION_LEVEL_DESCRIPTION":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">CERTIFICATION_LEVEL_DESCRIPTION</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CERTIFICATION_LEVEL_DESCRIPTION</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedDescription>" + xmlEncode(value) + "</cbc:ExpectedDescription>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:Description>" + xmlEncode(value) + "</cbc:Description>");


					}


					break;

				case "COPY_QUALITY_TYPE_CODE":
					if (bRequest == 1)
					{


						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">COPY_QUALITY_TYPE_CODE</cbc:ValueDataTypeCode>" & vbcrlf

						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">COPY_QUALITY_TYPE_CODE</cbc:ValueDataTypeCode>" + Environment.NewLine);


						if (TipoCriterion.ToUpper() == "REQUIREMENT" && !string.IsNullOrEmpty(value))
						{

							htmlToReturn.Write($@"<cbc:ExpectedCode>" + xmlEncode(value) + "</cbc:ExpectedCode>");

						}


					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseCode>" + xmlEncode(value) + "</cbc:ResponseCode>");


					}

					break;

				case "TIME":
					if (bRequest == 1)
					{

						//'response.write "<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.0"">TIME</cbc:ValueDataTypeCode>" & vbcrlf
						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">TIME</cbc:ValueDataTypeCode>" + Environment.NewLine);

						//'-- ci vuole un ExpectedXXX ? Quale ?

					}
					else
					{

						htmlToReturn.Write($@"<cbc:ResponseTime>" + xmlEncode(value) + "</cbc:ResponseTime>");

					}



					if (bRequest == 1)
					{
						htmlToReturn.Write($@"<cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">QUAL_IDENTIFIER</cbc:ValueDataTypeCode>");
					}
					else
					{

						if (!string.IsNullOrEmpty(value))
						{
							htmlToReturn.Write($@"<cbc:ResponseID schemeAgencyID=""EU-COM-GROW"">" + xmlEncode(value) + "</cbc:ResponseID>");
						}

					}


					break;

				default:
					htmlToReturn.Write($@"------------- [TIPO : """ + RG_FLD_TYPE + @""" NON GESTITO. FIELD : """ + CurField + @"""] -------------");
					break;
			}
		}

		public static object getNewGUID()
		{

			TSRecordSet rsTmp = objDB_MTR.GetRSReadFromQuery_("select NEWID() AS newGUID", ApplicationCommon.Application.ConnectionString);

			rsTmp.MoveFirst();

			return rsTmp.Fields["newGUID"];

			//set rsTmp = nothing

		}

		public static object getDomExtValue(string DM_ID, dynamic DMV_Cod)
		{


			if (CStr(DMV_Cod).Trim() == "")
			{
				return "";
			}

			TSRecordSet rsTmp = objDB_MTR.GetRSReadFromQuery_("select DMV_CodExt from LIB_DomainValues with(nolock) where DMV_DM_ID = '" + DM_ID.Replace("'", "''") + "' and DMV_Deleted = 0 and DMV_Cod = '" + DMV_Cod.Replace("'", "''") + "'", ApplicationCommon.Application.ConnectionString);

			if (rsTmp.RecordCount > 0)
			{

				rsTmp.MoveFirst();

				return CStr(rsTmp.Fields["DMV_CodExt"]);

				//set rsTmp = nothing

			}
			return "";

		}

		public static string getDomDescValue(string DM_ID, dynamic DMV_Cod)
		{


			if (CStr(DMV_Cod).Trim() == "")
			{
				//exit function
			}

			TSRecordSet rsTmp = objDB_MTR.GetRSReadFromQuery_("select DMV_DescML from LIB_DomainValues with(nolock) where DMV_DM_ID = '" + DM_ID.Replace("'", "''") + "' and DMV_Deleted = 0 and DMV_Cod = '" + CStr(DMV_Cod).Replace("'", "''") + "'", ApplicationCommon.Application.ConnectionString);

			if (rsTmp.RecordCount > 0)
			{

				rsTmp.MoveFirst();

				return CStr(rsTmp.Fields["DMV_DescML"]);

				//set rsTmp = nothing

			}
			return "";

		}

		public static void addEvidenceResponse(object questionIdEvidence, object url, object reference, object issuer, ref string listaResponseEvidence)
		{

			if (!string.IsNullOrEmpty(CStr(url)) || !string.IsNullOrEmpty(CStr(reference)) || !string.IsNullOrEmpty(CStr(issuer)))
			{

				string strEvidence = "<cac:Evidence>" + Environment.NewLine;
				strEvidence = strEvidence + @"	<cbc:ID schemeAgencyID=""EU-COM-GROW"">" + normalizeUUID(questionIdEvidence) + "</cbc:ID>" + Environment.NewLine;
				strEvidence = strEvidence + "	<cac:DocumentReference>" + Environment.NewLine;

				if (string.IsNullOrEmpty(CStr(reference)))
				{
					strEvidence = strEvidence + @"		<cbc:ID schemeAgencyID=""EU-COM-GROW""/>" + Environment.NewLine;
				}
				else
				{
					//'-- REFERENCE
					//'"MOD_" &  KeyModulo &  "_FLD_REF_"  &  CurField
					strEvidence = strEvidence + @"		<cbc:ID schemeAgencyID=""EU-COM-GROW"">" + xmlEncode(reference) + "</cbc:ID>" + Environment.NewLine;
				}

				if (!string.IsNullOrEmpty(CStr(url)))
				{
					//'-- URL
					//'"MOD_" &  KeyModulo &  "_FLD_URL_"  &  CurField 
					strEvidence = strEvidence + "		<cac:Attachment>" + Environment.NewLine;
					strEvidence = strEvidence + "			<cac:ExternalReference>" + Environment.NewLine;
					strEvidence = strEvidence + "				<cbc:URI>" + xmlEncode(url) + "</cbc:URI>" + Environment.NewLine;
					strEvidence = strEvidence + "			</cac:ExternalReference>" + Environment.NewLine;
					strEvidence = strEvidence + "		</cac:Attachment>" + Environment.NewLine;

				}

				if (!string.IsNullOrEmpty(CStr(issuer)))
				{

					//'-- ISSUER
					//'"MOD_" &  KeyModulo &  "_FLD_ISS_"  &  CurField 
					strEvidence = strEvidence + "		<cac:IssuerParty>" + Environment.NewLine;
					strEvidence = strEvidence + "			<cbc:WebsiteURI></cbc:WebsiteURI>" + Environment.NewLine;
					strEvidence = strEvidence + "			<cac:PartyName>" + Environment.NewLine;
					strEvidence = strEvidence + "				<cbc:Name>" + xmlEncode(issuer) + "</cbc:Name>" + Environment.NewLine;
					strEvidence = strEvidence + "			</cac:PartyName>" + Environment.NewLine;
					strEvidence = strEvidence + "		</cac:IssuerParty>" + Environment.NewLine;

				}

				strEvidence = strEvidence + "	</cac:DocumentReference>" + Environment.NewLine;
				strEvidence = strEvidence + "</cac:Evidence>" + Environment.NewLine;

				listaResponseEvidence = listaResponseEvidence + strEvidence;

			}

		}

		public static void aggiungiRapLeg(int idDoc, int iterazione, EprocResponse htmlToReturn)
		{

			string rapLegNome = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/FirstName", CStr(iterazione));
			string rapLegCognome = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/FamilyName", CStr(iterazione));

			string rapLegDataNascita = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/BirthDate", CStr(iterazione));

			if (!string.IsNullOrEmpty(rapLegDataNascita))
			{
				rapLegDataNascita = getTecDateNoTime(rapLegDataNascita);
			}

			string rapLegLuogoNascita = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/BirthplaceName", CStr(iterazione));

			string rapLegContactTel = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/Contact/Telephone", CStr(iterazione));
			string rapLegContactMail = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/Contact/ElectronicMail", CStr(iterazione));

			string rapLegCitta = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/CityName", CStr(iterazione));
			string rapLegCap = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/PostalZone", CStr(iterazione));

			string rapLegAddress = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/AddressLine/Line", CStr(iterazione));
			string rapLegCountry = getFieldValueFromPath(idDoc, "EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/Country/IdentificationCode", CStr(iterazione));

			if (string.IsNullOrEmpty(rapLegCountry))
			{
				rapLegCountry = "IT";
			}

			string rapLegCountryDesc = getDomDescValue("ISO3166_1_ALPHA2", rapLegCountry);


			htmlToReturn.Write($@"

		        <cac:PowerOfAttorney>
			        <cac:AgentParty>
				        <cac:Person>
					        <cbc:FirstName>" + xmlEncode(rapLegNome) + $@"</cbc:FirstName>
					        <cbc:FamilyName>" + xmlEncode(rapLegCognome) + $@"</cbc:FamilyName>			
					        <cbc:BirthDate>" + xmlEncode(rapLegDataNascita) + $@"</cbc:BirthDate>
					        <cbc:BirthplaceName>" + xmlEncode(rapLegLuogoNascita) + $@"</cbc:BirthplaceName>

	        ");
			if (!string.IsNullOrEmpty(rapLegContactTel) || !string.IsNullOrEmpty(rapLegContactMail))
			{
				htmlToReturn.Write($@"				
					            <cac:Contact>
				");
				addOptionalTag(rapLegContactTel, "cbc:Telephone", htmlToReturn);
				addOptionalTag(rapLegContactMail, "cbc:ElectronicMail", htmlToReturn);
				htmlToReturn.Write($@"
					            </cac:Contact>
	            ");
			}
			htmlToReturn.Write($@"				
					        <cac:ResidenceAddress>
			");
			addOptionalTag(rapLegCitta, "cbc:CityName", htmlToReturn);
			addOptionalTag(rapLegCap, "cbc:PostalZone", htmlToReturn);

			if (!string.IsNullOrEmpty(rapLegAddress))
			{
				htmlToReturn.Write($@"					
						            <cac:AddressLine>
							            <cbc:Line>" + xmlEncode(rapLegAddress) + $@"</cbc:Line>
						            </cac:AddressLine>
	            ");
			}
			htmlToReturn.Write($@"					
						        <cac:Country>
							        <cbc:IdentificationCode listID=""CountryCodeIdentifier"" listAgencyID=""ISO"" listName=""CountryCodeIdentifier"" listVersionID=""1.0"">" + rapLegCountry.ToUpper() + $@"</cbc:IdentificationCode>
							        <cbc:Name>" + rapLegCountryDesc + $@"</cbc:Name>
						        </cac:Country>
					        </cac:ResidenceAddress>
				        </cac:Person>
			        </cac:AgentParty>
		        </cac:PowerOfAttorney>

	        ");
		}

		public static void aggiungiContractingParty(object cfEnteMitt, object ragSocEnteMitt, object indirizzoEnteMitt, object comuneEnteMitt, object capEnteMitt, object rupNome, object rupTelefono, object rupEmail, object sitoWebAziMaster, object cfAziMaster, object ragSocAziMaster, EprocResponse htmlToReturn)
		{

			//'<!-- Obbligatorio. Cardinalità 1. L'ente che ha emesso la request -->
			htmlToReturn.Write($@"
			        <cac:ContractingParty>
				        <cbc:BuyerProfileURI>" + xmlEncode(sitoWebAziMaster) + $@"</cbc:BuyerProfileURI>
				        <cac:Party>
					        <cac:PartyIdentification>
	        ");
			//'					<!-- codice fiscale dell'ente. AdE = Agenzia delle entrate -->
			htmlToReturn.Write($@"							
						        <cbc:ID schemeID=""IT:CF"" schemeAgencyID=""AdE"">" + cfEnteMitt + $@"</cbc:ID>
					        </cac:PartyIdentification>
					        <cac:PartyName>
	        ");
			//'<!-- Ragione Sociale dell'ente -->  
			htmlToReturn.Write($@"
						        <cbc:Name>" + xmlEncode(ragSocEnteMitt) + $@"</cbc:Name>
					        </cac:PartyName>
					        <cac:PostalAddress>
						        <cbc:StreetName>" + xmlEncode(indirizzoEnteMitt) + $@"</cbc:StreetName>
						        <cbc:CityName>" + xmlEncode(comuneEnteMitt) + $@"</cbc:CityName>
						        <cbc:PostalZone>" + capEnteMitt + $@"</cbc:PostalZone>
						        <cac:Country>
							        <cbc:IdentificationCode listID=""CountryCodeIdentifier"" listAgencyID=""ISO"" listName=""CountryCodeIdentifier"" listVersionID=""1.0"">IT</cbc:IdentificationCode>
							        <cbc:Name>Italia</cbc:Name>
						        </cac:Country>
					        </cac:PostalAddress>
					
					        <!-- Info del rup -->
					        <cac:Contact>
						        <cbc:Name>" + xmlEncode(rupNome) + $@"</cbc:Name> 
	        ");
			addOptionalTag(rupTelefono, "cbc:Telephone", htmlToReturn);
			addOptionalTag(rupEmail, "cbc:ElectronicMail", htmlToReturn);
			htmlToReturn.Write($@"
					        </cac:Contact>
					        <!-- Soggetto che mette a disposizione la piattaforma su cui compilare l'ESPD  -->
					        <cac:ServiceProviderParty>
						        <cac:Party>
								        <cac:PartyIdentification> 
									        <cbc:ID schemeID=""IT:CF"" schemeAgencyID=""AdE"">" + cfAziMaster + $@"</cbc:ID>
								        </cac:PartyIdentification>
								        <cac:PartyName> 
									        <cbc:Name>" + xmlEncode(ragSocAziMaster) + $@"</cbc:Name>
								        </cac:PartyName>
								        <cac:PostalAddress> 
									        <cac:Country>
										        <cbc:IdentificationCode listID=""CountryCodeIdentifier"" listAgencyID=""ISO"" listName=""CountryCodeIdentifier"" listVersionID=""1.0"">IT</cbc:IdentificationCode>
									        </cac:Country>
								        </cac:PostalAddress>
						        </cac:Party>
					        </cac:ServiceProviderParty>
				        </cac:Party>
			        </cac:ContractingParty>
	        ");
		}

		public static void aggiungiProcurementProject(object titoloProcedura, object descrizioneProcedura, object ProjectType, object cpv, EprocResponse htmlToReturn)
		{
			//'	<!-- INIZIO BLOCCO PROCEDURA DI GARA -->
			//'		<!-- The REGULATED version should not contain a cac:ProcurementProject in order to ensure the back-wards compatibility with the version 1.0.2. -->
			//'		<!-- Use this component in case the ESPD is SELF-CONTAINED and the procedure is divided into lots. In this case use the ProcurementProjectLot component to provide details specific to the lot and reserve the ProcurementProject component to describe the global characteristics of the procedure. -->	
			//'		<!-- Self-contained ESPD Request. Data about the procurement procedure -->
			htmlToReturn.Write($@"		
			        <cac:ProcurementProject>
	        ");
			//'			<!-- Titolo della procedura di gara -->
			htmlToReturn.Write($@"
                        <cbc:Name>" + xmlEncode(titoloProcedura) + $@"</cbc:Name>

            ");
			//'			<!-- Descrizione della procedura di gara -->
			htmlToReturn.Write($@"			
				        <cbc:Description>" + xmlEncode(descrizioneProcedura) + $@"</cbc:Description> 
	        ");
			//'			<!-- Codice che descrive l'oggetto del progetto (es. lavori, forniture, servizi, concessioni di lavori pubblici, concessioni di servizi, ecc.) -->
			//'			<!-- Inserire il tipo di appalto in accordo alla Code List prevista -->
			if (!string.IsNullOrEmpty(CStr(ProjectType)))
			{
				htmlToReturn.Write($@"
				            <cbc:ProcurementTypeCode listID=""ProjectType"" listAgencyID=""EU-COM-OP"" listVersionID=""1.0"">" + ProjectType + $@"</cbc:ProcurementTypeCode>
	            ");
			}

			if (!string.IsNullOrEmpty(CStr(cpv)))
			{

				string[] vetCpv = Strings.Split(CStr(cpv), "###");

				for (int i = 0; i <= vetCpv.Length - 1; i++)
				{  //to ubound(vetCpv)

					string cpvX = vetCpv[i];

					if (!string.IsNullOrEmpty(cpvX))
					{

						object value = getDomExtValue("CODICE_CPV", cpvX);

						htmlToReturn.Write($@"
				                    <cac:MainCommodityClassification>
					                    <cbc:ItemClassificationCode listID=""CPV"" listAgencyName=""EU-COM-GROW"" listVersionID=""213/2008"">" + CStr(value) + $@"</cbc:ItemClassificationCode>
				                    </cac:MainCommodityClassification>
	                    ");
					}

				}

			}
			htmlToReturn.Write($@"

			        </cac:ProcurementProject>

	        ");
			//'	<!-- FINE BLOCCO PROCEDURA DI GARA -->
		}
		public static void addLotti(object idProcedura, int idDoc, int bFaseTest, object cfEnteMitt, EprocResponse htmlToReturn)
		{
			//'-- CAMBIARE GESTIONE!
			//'-- RECUPERARLO COME UN MULTIVALORE CON XPATH "ProcurementProjectLot/ID"


			//'		<!-- INIZIO BLOCCO LOTTI DELLA PROCEDURA DI GARA -->
			//'		<!-- Nel eDGUE-IT è obbligatorio specificare almeno un Lotto. Il lotto deve essere referenziato con il nome utilizzato nel bando di gara e con l'identificativo CIG emesso dall'ANAC. -->
			//'		<!-- Nel caso di lotto unico, l'ESPD si riferisce al progetto senza lotti -->
			//'		<!-- 1..N -->
			//'		<!-- Inserire la stringa formata da: Numero del lotto + "_" + CIG (es. LOTTO1_XXXXX) -->
			//'		<!-- TOLGO LO schemeAgencyID 'EU-COM-GROW' e metto ANAC, chiedere conferma in quanto questa indicazione non è presente nella documentazione italiana -->

			if (bFaseTest == 1)
			{// then

				string strSQLLotti = "select ID_LOTTO from ESPD_REQUEST_XML_LOTTI where idProcedura = " + CStr(idProcedura) + " order by numeroLotto";

				TSRecordSet RSLotti = cdf.GetRSReadFromQuery_(strSQLLotti, ApplicationCommon.Application.ConnectionString);

				if (RSLotti.RecordCount > 0)
				{// then

					RSLotti.MoveFirst();

					while (!RSLotti.EOF)
					{
						htmlToReturn.Write($@"
		                    <cac:ProcurementProjectLot>
			                    <cbc:ID schemeAgencyID=""" + CStr(cfEnteMitt) + $@""">" + xmlEncode(RSLotti.Fields["ID_LOTTO"]).Trim().ToUpper() + $@"</cbc:ID>
		                    </cac:ProcurementProjectLot>

	                    ");
						RSLotti.MoveNext();

					}

				}
			}
			else
			{
				string lotti = getFieldValueFromPath(idDoc, "ProcurementProjectLot/ID", "");

				if (!string.IsNullOrEmpty(lotti))
				{

					string[] vetLotti = Strings.Split(lotti, "###");

					for (int i = 0; i <= vetLotti.Length - 1; i++)
					{ //to ubound(vetLotti)

						string lotto = vetLotti[i];

						if (!string.IsNullOrEmpty(lotto))
						{
							htmlToReturn.Write($@"
		                        <cac:ProcurementProjectLot>
			                        <cbc:ID schemeAgencyID=""" + cfEnteMitt + $@""">" + xmlEncode(lotto).Trim() + $@"</cbc:ID>
		                        </cac:ProcurementProjectLot>

	                        ");
						}
					}
				}
			}
		}

		public static void addAdditionalDocumentReference(int idDoc, int bFaseTest, EprocResponse htmlToReturn)
		{
			string referenceID;
			if (bFaseTest == 1)
			{
				referenceID = "0000/S 000-000000";
			}
			else
			{
				referenceID = getFieldValueFromPath(idDoc, "AdditionalDocumentReference/ID", "");

				if (string.IsNullOrEmpty(CStr(referenceID)))
				{
					referenceID = "0000/S 000-000000";
				}
			}

			htmlToReturn.Write($@"
		        <cac:AdditionalDocumentReference>
			        <cbc:ID schemeAgencyID=""EU-COM-OP"">" + xmlEncode(referenceID) + $@"</cbc:ID> 
			        <cbc:DocumentTypeCode listID=""DocRefContentType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.0.2"">TED_CN</cbc:DocumentTypeCode> 
			        <cac:Attachment>
				        <cac:ExternalReference>
					        <cbc:Description/>
					        <cbc:Description/>
				        </cac:ExternalReference>
			        </cac:Attachment>
		        </cac:AdditionalDocumentReference>
	        ");

		}

		public static string getFieldValueFromPath(int idDoc, string pathXML, string iterazione)
		{
			//'--	idDoc del dgue, pathXML concordato per il campo ( e presente nella configurazione dei criteri ), numero dell'iterazione ( passare vuoto se l'elemento non è iterabile  )
			string strToReturn;
			if (string.IsNullOrEmpty(iterazione))
			{
				iterazione = "1";
			}

			strToReturn = "";

			string strSQL_F = "select dbo.ESPD_GET_FIELD_VALUE_FROM_PATH( " + idDoc + ", '" + pathXML.Replace("'", "''") + "', '" + iterazione.Replace("'", "''") + "') as val";

			TSRecordSet rsTmp = objDB_MTR.GetRSReadFromQuery_(strSQL_F, ApplicationCommon.Application.ConnectionString);

			if (rsTmp.RecordCount > 0)
			{
				rsTmp.MoveFirst();

				strToReturn = CStr(rsTmp.Fields["val"]);
			}

			return strToReturn;
		}

		public static void DrawSubCriteriaZero(object idModulo, int bloccaSottoCriteri, EprocResponse htmlToReturn)
		{
			string SQL;
			TSRecordSet rsCur3;

			if (bloccaSottoCriteri == 0)
			{
				//'-- escludo il sottocriterio 0 con uuid '7eab2b27-7f89-4de8-8c0a-a31c7bf8b8d3' perchè non ha la descrizione e fa andare in errore consip. in attesa della nuova tassonomia
				SQL = "select  isnull( m.Note , '' )  as Nota, isnull(Body,'') as Body, NumeroDocumento   "
						+ " from CTL_DOC m with(nolock) "
						+ " where   m.LinkedDoc = " + idModulo + " and  Tipodoc = 'TEMPLATE_REQUEST_GROUP' and deleted = 0 and versione = '00' and NumeroDocumento <> '7eab2b27-7f89-4de8-8c0a-a31c7bf8b8d3' ";

				//'response.write SQL

				rsCur3 = objDB_MTR.GetRSReadFromQuery_(SQL, ApplicationCommon.Application.ConnectionString);

				if (rsCur3.RecordCount > 0)
				{
					rsCur3.MoveFirst();
					while (!rsCur3.EOF)
					{
						object UUID = rsCur3.Fields["NumeroDocumento"];
						object DESCRIPTION = rsCur3.Fields["Nota"];
						object NAME = rsCur3.Fields["Body"];
						htmlToReturn.Write($@"
			                <!-- sotto criterio 0 -->
			                <cac:SubTenderingCriterion>
				                <cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(UUID) + $@"</cbc:ID>
				                <cbc:Name>" + xmlEncode(NAME).Trim() + $@"</cbc:Name>
				                <cbc:Description>" + xmlEncode(DESCRIPTION).Trim() + $@"</cbc:Description>
				                <cac:TenderingCriterionPropertyGroup>
					                <cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(getNewGUID()) + $@"</cbc:ID>
					                <cbc:PropertyGroupTypeCode listID=""PropertyGroupType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">ON*</cbc:PropertyGroupTypeCode>
					                <cac:TenderingCriterionProperty>
					                   <cbc:ID schemeID=""CriteriaTaxonomy"" schemeAgencyID=""EU-COM-GROW"" schemeVersionID=""2.1.1"">" + normalizeUUID(getNewGUID()) + $@"</cbc:ID>
					                   <cbc:Description/>
					                   <cbc:TypeCode listID=""CriterionElementType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">CAPTION</cbc:TypeCode>
					                   <cbc:ValueDataTypeCode listID=""ResponseDataType"" listAgencyID=""EU-COM-GROW"" listVersionID=""2.1.1"">NONE</cbc:ValueDataTypeCode>
					                </cac:TenderingCriterionProperty>
				                 </cac:TenderingCriterionPropertyGroup>
			                </cac:SubTenderingCriterion>
				
	                    ");
						rsCur3.MoveNext();
					}
				}
			}
		}
	}
}
