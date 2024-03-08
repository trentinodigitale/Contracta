//using System;
//using System.IO;
//using System.Runtime.Serialization;
//using System.Runtime.Serialization.Json;
//using System.Text;

//namespace INIPEC.eForms
//{

//    [DataContract]
//    public class Person
//    {
//        [DataMember(Name = "first_name")]
//        public string FirstName { get; set; }

//        [DataMember(Name = "last_name")]
//        public string LastName { get; set; }

//        [DataMember(Name = "age")]
//        public int? Age { get; set; }
//    }

//    public class MyDataContractJsonSerializer<T> where T : class
//    {
//        public string Serialize(T obj)
//        {
//            var serializer = new DataContractJsonSerializer(typeof(T), GetJsonSettings());

//            using (var memoryStream = new MemoryStream())
//            {
//                serializer.WriteObject(memoryStream, obj);
//                return Encoding.UTF8.GetString(memoryStream.ToArray());
//            }
//        }

//        private JsonSerializerSettings GetJsonSettings()
//        {
//            return new JsonSerializerSettings
//            {
//                NullValueHandling = NullValueHandling.Ignore
//            };
//        }
//    }

//    class Program
//    {
//        static void Main()
//        {
//            var person = new Person
//            {
//                FirstName = "John",
//                LastName = null,
//                Age = null
//            };

//            var mySerializer = new MyDataContractJsonSerializer<Person>();
//            var json = mySerializer.Serialize(person);

//            Console.WriteLine(json);
//        }
//    }

//}