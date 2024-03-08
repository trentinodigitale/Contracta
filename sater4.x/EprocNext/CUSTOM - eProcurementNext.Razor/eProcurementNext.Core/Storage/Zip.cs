using System.IO.Compression;
//using ICSharpCode.SharpZipLib.Zip;
// verificare performance FastZip (SharpZipLib) e ZipFile (.NET Core)

namespace eProcurementNext.Razor
{
    public class Zip
    {
        private string strErrDescription = "";

        public bool PackIsEmpty(string pathFileZip)
        {
            bool ret = false;
            using (ZipArchive archive = ZipFile.Open(pathFileZip, ZipArchiveMode.Read))
            {
                int fileCount = archive.Entries.Count;
                ret = fileCount == 0;
            }

            return ret;
		}

        public bool UnPack(string pathFileZip, string pathExtractTo)
        {
            return unpackExt(pathFileZip, pathExtractTo, "");
        }

        public bool unpackExt(string pathFileZip, string pathExtractTo, string fileFilter)
        {

            bool out_ = false;
            string strCause = "";

            strErrDescription = "";

            if (File.Exists(pathFileZip))
            {

                try
                {

                    strCause = "creazione oggetto della classe ICSharpCode.SharpZipLib.Zip.FastZip";
                    //FastZip utils = new FastZip();

                    strCause = "invocazione metodo ExtractZip della classe FastZip";
                    ZipFile.ExtractToDirectory(pathFileZip, pathExtractTo);
                    //utils.ExtractZip(pathFileZip, pathExtractTo, fileFilter);

                    out_ = true;
                    strErrDescription = "";

                }
                catch (Exception ex)
                {
                    strErrDescription = "Errore in " + strCause + " - " + ex.ToString();
                }

            }
            else
            {

                strErrDescription = "File non presente nel percorso specificato";

            }

            return out_;

        }

        public bool Pack(string directoryToZip, string pathFileZip)
        {

            bool out_ = false;
            string strCause = "";

            strErrDescription = "";

            if (Directory.Exists(directoryToZip))
            {

                try
                {

                    strCause = "invocazione metodo CreateFromDirectory della classe ZipFile";
                    ZipFile.CreateFromDirectory(directoryToZip, pathFileZip);
                    //utils.CreateZip(pathFileZip, directoryToZip, true, "");


                    if (File.Exists(pathFileZip))
                    {
                        strErrDescription = "";
                        out_ = true;
                    }
                    else
                    {
                        strErrDescription = "Errore nella generazione del file zip";
                        out_ = false;
                    }

                }
                catch (Exception ex)
                {
                    strErrDescription = "Errore in " + strCause + " - " + ex.ToString();
                }

            }
            else
            {

                strErrDescription = "Directory da zippare non presente nel percorso specificato";

            }

            return out_;

        }

        public string ErrorDescription()
        {
            return strErrDescription;
        }

        public string testDirectoryAccess(string directoryToZip)
        {

            string out_ = "";

            try
            {

                if (Directory.Exists(directoryToZip))
                {
                    out_ = "OK";
                }
                else
                {
                    out_ = "Directory.Exists di '" + directoryToZip + "' ritorna false";
                }

            }
            catch (Exception ex)
            {
                out_ = "ERRORE:" + ex.ToString();
            }

            return out_;

        }

        public string testFileAccess(string pathFile)
        {

            string out_ = "";

            try
            {

                if (File.Exists(pathFile))
                {
                    out_ = "OK";
                }
                else
                {
                    out_ = "File.Exists di '" + pathFile + "' ritorna false";
                }

            }
            catch (Exception ex)
            {
                out_ = "ERRORE:" + ex.ToString();
            }

            return out_;

        }

    }

}