using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace FTM.Cloud.Common.Helpers
{
    public class Utils
    {
        public static bool Compare<TC>(TC Object1, TC object2)
        {
            //Get the type of the object
            Type type = typeof(TC);

            //return false if any of the object is false
            if (object.Equals(Object1, default(TC)) || object.Equals(object2, default(TC)))
                return false;

            //Loop through each properties inside class and get values for the property from both the objects and compare
            foreach (PropertyInfo property in type.GetProperties())
            {
                if (property.Name != "ExtensionData")
                {
                    string Object1Value = string.Empty;
                    string Object2Value = string.Empty;

                    if (type.GetProperty(property.Name).GetValue(Object1, null) != null)
                        Object1Value = type.GetProperty(property.Name).GetValue(Object1, null).ToString();

                    if (type.GetProperty(property.Name).GetValue(object2, null) != null)
                        Object2Value = type.GetProperty(property.Name).GetValue(object2, null).ToString();

                    if (Object1Value.Trim() != Object2Value.Trim())
                        return false;
                }
            }
            return true;
        }

        /// <summary>
        /// Copy an object to destination object, only matching fields will be copied
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="sourceObject">An object with matching fields of the destination object</param>
        /// <param name="destObject">Destination object, must already be created</param>
        public static void CopyObject<T>(object sourceObject, ref T destObject)
        {
            //	If either the source, or destination is null, return
            if (sourceObject == null || destObject == null)
                return;

            //	Get the type of each object
            Type sourceType = sourceObject.GetType();
            Type targetType = destObject.GetType();

            //	Loop through the source properties
            foreach (PropertyInfo p in sourceType.GetProperties())
            {
                //	Get the matching property in the destination object
                PropertyInfo targetObj = targetType.GetProperty(p.Name);
                //	If there is none, skip
                if (targetObj == null)
                    continue;

                if (targetObj.GetSetMethod() != null && sourceType == targetType)
                {
                    //	Set the value in the destination
                    targetObj.SetValue(destObject, p.GetValue(sourceObject, null), null);
                }
            }
        }

        /// <summary>
        /// Gets a boolean value of a data reader by a column name
        /// </summary>
        public static bool GetBoolean(object valueConv)
        {

            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()))
            {
                return false;
            }
            return Convert.ToBoolean(valueConv);
        }

        /// <summary>
        /// Gets a byte array of a data reader by a column name
        /// </summary>
        public static byte[] GetBytes(object valueConv)
        {

            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()))
            {
                return null;
            }
            return (byte[])valueConv;
        }




        /// <summary>
        /// Gets a decimal value of a data reader by a column name
        /// </summary>
        public static decimal GetDecimal(object valueConv)
        {

            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()) || !IsNumeric(valueConv.ToString()))
            {
                return decimal.Zero;
            }
            return Convert.ToDecimal(valueConv);
        }

        /// <summary>
        /// Gets a double value of a data reader by a column name
        /// </summary>
        public static double GetDouble(object valueConv)
        {

            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()))
            {
                return 0.0;
            }
            return Convert.ToDouble(valueConv);
        }

        /// <summary>
        /// Gets a GUID value of a data reader by a column name
        /// </summary>
        public static Guid GetGuid(object valueConv)
        {

            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()))
            {
                return Guid.Empty;
            }
            return (Guid)valueConv;
        }

        /// <summary>
        /// Gets an integer value of a data reader by a column name
        /// </summary>
        public static int GetInt(object valueConv)
        {
            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString().Trim()) || !IsNumeric(valueConv.ToString()))
            {
                return 0;
            }
            return Convert.ToInt32(valueConv);
        }

        public static Int64 GetLong(object valueConv)
        {
            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString().Trim()) || !IsNumeric(valueConv.ToString()))
            {
                return 0;
            }
            return Convert.ToInt64(valueConv);
        }



        /// <summary>
        /// Gets a short value of a data reader by a column name
        /// </summary>
        public static short GetShort(object valueConv)
        {
            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString().Trim()) || !IsNumeric(valueConv.ToString()))
            {
                return 0;
            }
            return Convert.ToInt16(valueConv);
        }

        /// <summary>
        /// Gets a nullable integer value of a data reader by a column name
        /// </summary>
        public static int? GetNullableInt(object valueConv)
        {
            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()) || !IsNumeric(valueConv.ToString()))
            {
                return null;
            }
            return Convert.ToInt32(valueConv);
        }

        /// <summary>
        /// Gets a string of a data reader by a column name
        /// </summary>
        /// <returns>A string value</returns>
        public static string GetString(object valueConv)
        {
            if (valueConv == null || String.IsNullOrEmpty(valueConv.ToString()))
            {
                return string.Empty;
            }
            return valueConv.ToString();
        }

        public static bool IsNumeric(string sText)
        {
            if (string.IsNullOrEmpty(sText)) return false;
            string ValidChars = "0123456789.,-";
            bool IsNumber = true;
            string Char;
            for (int i = 0; i < sText.Length && IsNumber == true; i++)
            {
                Char = sText.Substring(i, 1);
                if (ValidChars.IndexOf(Char) == -1)
                {
                    IsNumber = false;
                }
            }

            return IsNumber;
        }

        public static bool IsNumeric(object sVal)
        {
            if (sVal == null || sVal == System.DBNull.Value)
                return false;
            string sText = sVal.ToString();
            if (string.IsNullOrEmpty(sText)) return false;
            string ValidChars = "0123456789.,";
            bool IsNumber = true;
            string Char;
            for (int i = 0; i < sText.Length && IsNumber == true; i++)
            {
                Char = sText.Substring(i, 1);
                if (ValidChars.IndexOf(Char) == -1)
                {
                    IsNumber = false;
                }
            }

            return IsNumber;
        }

        public static string GeneratePassword(string MapPassword)
        {
            /*
             * I valori interpretati in MapPassword sono soltanto
             * a = Lettera minuscola casuale
             * A = Lettera maisucola casuale
             * 0 = Numero casuale
             * qualisiasi altra lettera verrà messa così come è senza codificarla
            */
            int stringLength = MapPassword.Length;

            Random rnd = new Random((int)System.DateTime.Now.Ticks);
            StringBuilder randomText = new StringBuilder(stringLength);

            //value of A in ascii codes
            int minValueMaiusc = 65;
            //value of Z in ascii codes
            int maxValueMaiusc = 90;


            //value of "a" in ascii codes
            int minValueMinusc = 97;
            //value of "z" in ascii codes
            int maxValueMinusc = 122;


            //value of "0" in ascii codes
            int minValueDigit = 48;
            //value of "9" in ascii codes
            int maxValueDigit = 57;

            //the range that we are allowed to go above the min value
            int randomRangeMaiusc = maxValueMaiusc - minValueMaiusc;
            int randomRangeMinusc = maxValueMinusc - minValueMinusc;
            int randomRangeDigit = maxValueDigit - minValueDigit;


            double rndValue;
            char[] mapChar = MapPassword.ToCharArray();

            for (int i = 0; i < stringLength; i++)
            {
                rndValue = rnd.NextDouble();
                if (mapChar[i].Equals(Convert.ToChar("A")))
                    randomText.Append((char)(minValueMaiusc + rndValue * randomRangeMaiusc));
                else if (mapChar[i].Equals(Convert.ToChar("a")))
                    randomText.Append((char)(minValueMinusc + rndValue * randomRangeMinusc));
                else if (mapChar[i].Equals(Convert.ToChar("0")))
                    randomText.Append((char)(minValueDigit + rndValue * randomRangeDigit));
                else
                    randomText.Append(mapChar[i]);
            }

            return randomText.ToString();
        }

        public static DateTime GetDateTime(object p)
        {
            DateTime dRes = DateTime.Now;
            if (p == null || String.IsNullOrEmpty(p.ToString()) || !DateTime.TryParse(p.ToString(), out dRes))
                return DateTime.Now;
            else
                return (DateTime)p;
        }

        public static DateTime? GetDateTimeNullable(object p)
        {
            DateTime tmp;
            if (p == null || String.IsNullOrEmpty(p.ToString()) || !DateTime.TryParse(p.ToString(), out tmp))
            {
                return null;
            }
            else
            {
                return (DateTime)p;
            }
        }


        private static string[] supportedFormatsDate = new String[] { "G", "g", "f", "F", "dd/MM/yyyy", "MM/dd/yyyy", "MM/dd/yyyy HH:mm:ss", "M/d/yyyy HH:mm:ss", "M/dd/yyyy HH:mm:ss", "yyyy-MM-dd", "yyyy/MM/dd", "yyyy/MM/d hh:mm", "yyyy/MM/dd hh:mm", "yyyy/MM/dd h:mm",
                                                       "yyyy/MM/dd HH:mm:ss", "yyyy/MM/dd H:mm:ss", "yyyy/MM/dd H:mm:ss","dd/MM/yyyy HH.mm.ss" }; //

        /// <summary>
        /// Convert datetime value of a data reader by a column name
        /// </summary>
        public static DateTime GetDateTime2(object valueConv)
        {
            string sValueConv = GetString(valueConv);
            DateTime resDate = DateTime.ParseExact(sValueConv, supportedFormatsDate, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None);
            return resDate;

        }

        public static bool isValidDate(string valueDate)
        {

            DateTime dateValue;

            try
            {
                if (DateTime.TryParseExact(valueDate, supportedFormatsDate,
                                               System.Globalization.CultureInfo.InvariantCulture,
                                               DateTimeStyles.None,
                                               out dateValue))
                {
                    Console.WriteLine("Converted '{0}' to {1}.", valueDate, dateValue);
                    return true;
                }
                else
                {
                    Console.WriteLine("Unable to convert '{0}' to a date.", valueDate);
                    return false;
                }
            }
            catch
            {
                return false;
            }
        }

        public static string GetMD5Hash(string value)
        {
            MD5 md5Hasher = MD5.Create();
            byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(value));
            StringBuilder sBuilder = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }
            return sBuilder.ToString();
        }

        /// <summary>
        /// Creates a salt
        /// </summary>
        /// <param name="size">A salt size</param>
        /// <returns>A salt</returns>
        private static string CreateSalt(int size)
        {
            RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
            byte[] data = new byte[size];
            provider.GetBytes(data);
            return Convert.ToBase64String(data);
        }

        /// <summary>
        /// Creates a salt
        /// </summary>
        /// <param name="size">Check Overlapping Range Date</param>
        /// <returns>A salt</returns>
        public static bool VerificaSovrapposizioneRangeDate(DateTime ev1Begin, DateTime ev1End, DateTime ev2Begin, DateTime ev2End)
        {
            if (ev1Begin > ev1End || ev2Begin > ev2End)
            {
                //return true;  // se le date sono invertite indico come periodo sovrapposto
                // in alternativa
                throw new Exception("Date invertite!");
            }

            if ((ev1Begin <= ev2Begin && ev1End >= ev2End)  // 1 e 5
              || (ev1Begin >= ev2Begin && ev1End <= ev2End) // 2, 6 e 7
              || (ev1Begin < ev2Begin && ev1End > ev2Begin) // 3
              || (ev1Begin < ev2End && ev1End > ev2End)     // 4
              )
                return false;
            else
                return true;
        }

        public static string NumberDecimalSeparator()
        {
            //return CultureInfo.CurrentUICulture.NumberFormat.NumberDecimalSeparator;//
            return (1.0 / 2.0).ToString().IndexOf(".") > -1 ? "." : ",";
        }

        public static string GeneraPassword()
        {
            Int32 length = 8;
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
            StringBuilder res = new StringBuilder();
            Random rnd = new Random();
            while (0 < length--)
            {
                res.Append(valid[rnd.Next(valid.Length)]);
            }
            return res.ToString();
        }


        private const string ENCRYPTION_KEY = "JHBasdHGHCGBJKbjkvhbHVJh";

        public static String Encrypt(String text)
        {
            if (text == null)
            {
                return null;
            }
            byte[] bytesBuff = Encoding.Unicode.GetBytes(text);
            using (Aes aes = Aes.Create())
            {
                Rfc2898DeriveBytes crypto = new Rfc2898DeriveBytes(ENCRYPTION_KEY, new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });
                aes.Key = crypto.GetBytes(32);
                aes.IV = crypto.GetBytes(16);
                using (MemoryStream mStream = new MemoryStream())
                {
                    using (CryptoStream cStream = new CryptoStream(mStream, aes.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cStream.Write(bytesBuff, 0, bytesBuff.Length);
                        cStream.Close();
                    }
                    text = Convert.ToBase64String(mStream.ToArray());
                }
            }
            return text;
        }

        public static String Decrypt(String cryptedTxt)
        {
            if (cryptedTxt == null || cryptedTxt == "")
            {
                return null;
            }
            String res = cryptedTxt.Replace(" ", "+");
            byte[] bytesBuff = Convert.FromBase64String(res);
            using (Aes aes = Aes.Create())
            {
                Rfc2898DeriveBytes crypto = new Rfc2898DeriveBytes(ENCRYPTION_KEY, new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });
                aes.Key = crypto.GetBytes(32);
                aes.IV = crypto.GetBytes(16);
                using (MemoryStream mStream = new MemoryStream())
                {
                    using (CryptoStream cStream = new CryptoStream(mStream, aes.CreateDecryptor(), CryptoStreamMode.Write))
                    {
                        cStream.Write(bytesBuff, 0, bytesBuff.Length);
                        cStream.Close();
                    }
                    res = Encoding.Unicode.GetString(mStream.ToArray());
                }
            }
            return res;
        }

        public static string ComputeSha256Hash(string rawData)
        {
            // Create a SHA256
            using (SHA256 sha256Hash = SHA256.Create())
            {
                // ComputeHash - returns byte array
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));

                // Convert byte array to a string
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }


        public static async Task<string> GetResponseString(string baseUrl, string endPoint, string requestBody)
        {
            var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri((string)baseUrl);
            var response = await httpClient.PostAsync((string)endPoint, new StringContent(requestBody, Encoding.UTF8, "application/json"));
            var contents = await response.Content.ReadAsStringAsync();
            return contents;
        }

        public static async Task<HttpResponseMessage> GetResponse(string baseUrl, string endPoint, string requestBody)
        {
            var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri((string)baseUrl);
            var response = await httpClient.PostAsync((string)endPoint, new StringContent(requestBody, Encoding.UTF8, "application/json"));

            return response;
        }

        public static async Task<HttpResponseMessage> GetDelete(string baseUrl, string endPoint, NameValueCollection nvc)
        {
            var queryString = ToQueryString(nvc);
            var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri((string)baseUrl);
            var response = await httpClient.DeleteAsync((string)endPoint+queryString);
            //var response = await httpClient.PostAsync((string)endPoint, new StringContent(requestBody, Encoding.UTF8, "application/json"));

            return response;
        }

        public static async Task<HttpResponseMessage> GetDeleteByRequestBody(string baseUrl, string endPoint, string requestBody)
        {
            var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri((string)baseUrl);
            var response = await httpClient.SendAsync(new HttpRequestMessage(HttpMethod.Delete, endPoint){Content = new StringContent(requestBody, Encoding.UTF8, "application/json")});
            return response;
        }

        private static string ToQueryString(NameValueCollection nvc)
        {
            var array = (from key in nvc.AllKeys
                         from value in nvc.GetValues(key)
                         select string.Format("{0}={1}", HttpUtility.UrlEncode(key), HttpUtility.UrlEncode(value)))
                .ToArray();
            return "?" + string.Join("&", array);
        }

    }
}
