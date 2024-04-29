using eProcurementNext.CommonDB;
using System.Xml;

namespace ParixClient
{

	public static class Utils
    {
        private static CommonDbFunctions cdf = new();
        //private static string connectionString = ApplicationCommon.Application["ConnectionString"]

        public static void addFieldToCollection(XmlNode node, string xpath, Dictionary<string, object> collection, string key)
        {
            XmlNodeList m_nodelist = null;

            m_nodelist = node.SelectNodes(xpath);

            // -- aggiunto l'elemento alla collezione se l'espressione xpath mi ha ritornato qualcosa
            if (m_nodelist.Count > 0)
            {
                collection.Add(key, m_nodelist[0].InnerText);
            }

            m_nodelist = null;
        }

        public static string getXPathValue(XmlNode node, string xpath)
        {
            string getXPathValueRet = default;

            XmlNodeList m_nodelist = null;

            m_nodelist = node.SelectNodes(xpath);

            getXPathValueRet = "";

            // -- aggiunto l'elemento alla collezione se l'espressione xpath mi ha ritornato qualcosa
            if (m_nodelist.Count > 0)
            {
                getXPathValueRet = m_nodelist[0].InnerText;
            }

            m_nodelist = null;
            return getXPathValueRet;

        }

        public static string getDescFormaSoc(string codXmlParix, string connectionString)
        {
            string getDescFormaSocRet = default;

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@codXmlParix", codXmlParix);
			string strSql = "select dscTesto as Descrizione from tipidatirange, descsI where tdridtid = 131 and tdrdeleted=0 and IdDsc =  tdriddsc and isnull(tdrCodiceEsterno,'') = @codXmlParix";

            //var db = new ParixClient.Db(connectionString)
            string val = string.Empty;

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, connectionString, sqlParams);

            //val = db.getSqlValueFromQuery(strSql, "Descrizione"))  // TODO: getSqlValueFromQuery sarà modificato / Eliminato 

            if (rs is not null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                val = rs[0].ToString();
            }

            getDescFormaSocRet = string.Empty;

            if (!string.IsNullOrEmpty(val))
            {
                getDescFormaSocRet = val;
            }

            return getDescFormaSocRet;
        }

        public static void getComune(string codComune, ref string dmv_cod, ref string dom_desc, string connectionString)
        {
            //var db = new ParixClient.Db(connectionString)

            //strSql = " declare @val as int" + Environment.NewLine
            //strSql = strSql + "set @val = " + codComune + Environment.NewLine // diventa un numero e si elimina lo zero a sx

            int _codComune = int.Parse(codComune);

            string strSql = $"select dmv_descml,dmv_cod from lib_domainvalues where dmv_cod LIKE '%-{_codComune}' and dmv_dm_id = 'GEO' and DMV_Level = 7";

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, connectionString);

            if (rs is not null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                dmv_cod = rs["dmv_cod"].ToString();
                dom_desc = rs["dmv_descml"].ToString();
            }
        }

        public static string getProvincia(string codProvincia, string connectionString)
        {
            string getProvinciaRet = default;

            string strSql = "";
            //var db = new ParixClient.Db(connectionString)

            strSql = $"select dmv_descml from lib_domainvalues where dmv_dm_id = 'geo' and dmv_cod = '{codProvincia}' and DMV_Level = 6";
            getProvinciaRet = "";

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, connectionString);

            if (rs is not null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                getProvinciaRet = rs["dmv_descml"].ToString();
            }
            return getProvinciaRet;
        }

        public static int getRuoloRapLeg(string carica, string connectionString)
        {
            int getRuoloRapLegRet = -1;

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@carica", carica);
			string strSql = $"SELECT REL_ValueOutput as Ruolo from CTL_Relations where REL_Type = 'RUOLI_RAPLEG' and REL_ValueInput =@carica";
            string val = string.Empty;

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, connectionString, sqlParams);
            if (rs is not null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                val = rs["Ruolo"].ToString() ?? null;
            }

            //val = Conversions.ToString(db.getSqlValueFromQuery(strSql, "Ruolo"))
            //getRuoloRapLegRet = -1

            // -- Se la carica passata è una delle cariche che identificano un rappresentante legale
            if (!string.IsNullOrEmpty(val))
            {
                //int ruolo = Conversions.ToInteger(val)

                getRuoloRapLegRet = int.Parse(val);
            }

            return getRuoloRapLegRet;
        }

        public static void traceXmlParix(string xmlParix, string tipoXml, string sessionid, string codice_fiscale, string connectionString)
        {
            Dictionary<string, object?>? paramDict = new Dictionary<string, object?>();
            paramDict.Add("@parCF", codice_fiscale);
            paramDict.Add("@parTipoXml", $"XML_PARIX_{tipoXml}");
            paramDict.Add("@parXmlParix", xmlParix);

            string strSql = "INSERT INTO Parix_Dati(sessionid,codice_fiscale,nome_campo,valore) VALUES('LOG_PARIX', @parCF,@partipoXml,@parXmlParix)";

            cdf.Execute(strSql, connectionString, parCollection: paramDict);
        }

        public static void traceXmlParixImport(string xmlParix, string codice_fiscale, string connectionString)
        {
            string strSql = "";
            string val = "";
            //var db = new ParixClient.Db(connectionString)

            strSql = $"INSERT INTO CTL_LOG_UTENTE(datalog,paginaDiArrivo,descrizione,form) VALUES(getdate(),'PARIX_CLIENT_IMPORT',@parCF,'{xmlParix.Replace("'", "''")}')";
            cdf.Execute(strSql, connectionString);

            //db.execSqlNoTransaction(strSql)
        }

        public static void insertCollectionInDb(Dictionary<string, object> dati, string sessionid, string codice_fiscale, string connectionString)
        {
            string strSql = "";
            string val = "";
            var db = new ParixClient.Db(connectionString);

            // -- pulisco la tabella da precedenti import a parità di sessionId e codiceFiscale
            //db.execSqlNoTransaction($"delete from Parix_Dati where sessionid = '{sessionid.Replace("'", "''")}' and codice_fiscale = '{codice_fiscale}'")
            cdf.Execute($"delete from Parix_Dati where sessionid = '{sessionid.Replace("'", "''")}' and codice_fiscale = '{codice_fiscale}'", connectionString);

            foreach (KeyValuePair<string, object> item in dati)
            {
                strSql = "INSERT INTO Parix_Dati(sessionid,codice_fiscale,nome_campo,valore)";
                strSql = strSql + $" VALUES('{sessionid}','{codice_fiscale}','{item.Key.Replace("'", "''")}','{item.Value.ToString().Replace("'", "''")}')";

                //db.execSqlNoTransaction(strSql)
                cdf.Execute(strSql, connectionString);
            }
        }

        public static string getSYS(string connectionString, string sysName)
        {
            string getSYSRet = default;

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@sysName", $"SYS_{sysName}");
			string strSql = $"select DZT_ValueDef from LIB_Dictionary with(nolock) where DZT_Name = @sysName";

            //var db = new ParixClient.Db(connectionString)
            //string val = ""

            TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, connectionString);
            if (rs != null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                getSYSRet = rs["DZT_ValueDef"].ToString();
            }

            return getSYSRet;
        }
    }
}