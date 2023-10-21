using System.Text;

namespace VoiSlateParser.Helper;

public class EncodingHelper
{
    private static Encoding gbkEnc = Encoding.GetEncoding("gbk");
    private static Encoding utfEnc = Encoding.Unicode;
    
    public static string ConvertUtfToIso(string uft)
    {
        // Define the UTF-16 encoded string

        // Convert the UTF-16 string to a byte array using UTF-16 encoding
        byte[] utfBuffer = utfEnc.GetBytes(uft);

        // Convert the UTF-16 byte array to ISO-8859-1 byte array
        byte[] gbkBuffer = Encoding.Convert(utfEnc, gbkEnc, utfBuffer);

        // Convert the ISO-8859-1 byte array to a string
        string gbk = gbkEnc.GetString(gbkBuffer);

        return gbk;
    }
}