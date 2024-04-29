using System.Security.Cryptography;
using System.Text;

namespace eProcurementNext.CommonModule
{
    public static class FileHash
    {

        public static class Algorithm
        {
            public const string SHA1 = "SHA1";
            public const string SHA256 = "SHA256";
            public const string MD5 = "MD5";
        }

        public static string GetHashFile(string algoritmoHashFile, string pathFile)
        {

            if (!File.Exists(pathFile))
            {
                throw new Exception("FILE NON TROVATO. " + pathFile);
            }

            string strOut = "";
            int totTentativi = 0;
            bool fileBloccato = true;

            HashAlgorithm? hashAlgorithm = null;
            Exception? ex = null;

            while (totTentativi < 5 && fileBloccato)
            {
                try
                {
                    totTentativi++;

                    switch (algoritmoHashFile.ToUpper())
                    {
                        case Algorithm.SHA1:
                            hashAlgorithm = SHA1.Create();
                            break;
                        case Algorithm.SHA256:
                            hashAlgorithm = SHA256.Create();
                            break;
                        case Algorithm.MD5:
                            hashAlgorithm = MD5.Create();
                            break;
                        default:
                            throw new Exception("0#ALGORITMO DI HASH '" + algoritmoHashFile + "' NON SUPPORTATO");
                    }

                    if (hashAlgorithm == null)
                    {
                        throw new Exception("0#ALGORITMO DI HASH '" + algoritmoHashFile + "' NON SUPPORTATO");
                    }

                    strOut = GetHash(hashAlgorithm, pathFile);

                    //Facciamo finire il ciclo while
                    fileBloccato = false;
                }
                catch (Exception e)
                {
                    ex = e;

                    Thread.Sleep(500);
                }
                finally
                {
                    if (hashAlgorithm != null)
                    {
                        hashAlgorithm.Dispose();
                    }
                }
            }

            if (ex != null)
            {
                throw ex;
            }

            if (string.IsNullOrEmpty(strOut))
                throw new Exception("GetHashFile() - Hash Binario del file non generato");

            return strOut;
        }


        private static string GetSha1FileHash(string pathFile)
        {
            string outHash = "";

            using (SHA1 hash = SHA1.Create())
            {
                outHash = GetHash(hash, File.ReadAllText(pathFile));
            }
            return outHash;
        }

        public static string GetSha256FileHash(string pathFile)
        {
            string outHash = "";

            using (SHA256 hash = SHA256.Create())
            {
                outHash = GetHash(hash, pathFile);
            }
            return outHash;
        }

        private static string GetMD5FileHash(string pathFile)
        {
            string outHash = "";

            using (MD5 hash = MD5.Create())
            {
                outHash = GetHash(hash, File.ReadAllText(pathFile));
            }
            return outHash;
        }

        public static string GetHash(HashAlgorithm hashAlgorithm, string path)
        {
            string hash = "";

            using var fileStream = File.Open(path, FileMode.Open, FileAccess.Read);
            byte[] data = hashAlgorithm.ComputeHash(fileStream);
            var sBuilder = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
            {
	            sBuilder.Append(data[i].ToString("x2"));
            }
            hash = sBuilder.ToString().ToUpper();

            return hash;
        }

        public static string GetHashFromString(string algoritmoHashFile, string input)
        {
            HashAlgorithm? hashAlgorithm = null;

            switch (algoritmoHashFile.ToUpper())
            {
                case Algorithm.SHA1:
                    hashAlgorithm = SHA1.Create();
                    break;
                case Algorithm.SHA256:
                    hashAlgorithm = SHA256.Create();
                    break;
                case Algorithm.MD5:
                    hashAlgorithm = MD5.Create();
                    break;
                default:
                    throw new Exception("0#ALGORITMO DI HASH '" + algoritmoHashFile + "' NON SUPPORTATO");
            }
            if (hashAlgorithm is null)
            {
                throw new Exception("0#ALGORITMO DI HASH '" + algoritmoHashFile + "' NON SUPPORTATO");
            }

            byte[] data = hashAlgorithm.ComputeHash(Encoding.UTF8.GetBytes(input));
            var sBuilder = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }
            return sBuilder.ToString();
        }
    }
}
