
using System.Globalization;
using CsvHelper.Configuration;
using CsvHelper;
using System.Data;
using System.Text.RegularExpressions;
using System.IO;
using System;
using System.Collections.Generic;
using System.Linq;

namespace VoiSlateParser.Utilities;

public class AlePaser : IDisposable
{
    CsvConfiguration config = new (CultureInfo.InvariantCulture)
    {
        Delimiter = ",",
        WhiteSpaceChars = new[] { ' ' },
        NewLine = "\r\n",
    };
    CsvConfiguration aleConfig = new (CultureInfo.InvariantCulture)
    {
        Delimiter = "\t",
        WhiteSpaceChars = new[] { ' ' },
        NewLine = "\r\n"
    };
    MemoryStream stream = new();
    StreamWriter tempwriter;
    StreamReader tempreader;
    public string Heading = string.Empty;
    public string Column = string.Empty;
    public string DataTrunk = string.Empty;
    public DataTable dt = new();
    public string parserType = "csv";

    public AlePaser(FileInfo path)
    {
        tempwriter = new(stream);
        tempreader = new(stream);
        if (path.Extension.ToLower() == ".ale")
        {
            parserType = "ale";
            ParseAle(path.FullName);
        }
        else if (path.Extension.ToLower() == ".csv")
        {
            parserType = "csv";
            ParseCsv(path.FullName);
        }
        GenerateDataTable();
    }

    private void ParseCsv(string path)
    {
        string line = string.Empty;
        using (StreamReader reader = new(path))
        {
            // assert the first line is not blank
            var csvHead = reader.ReadLine();
            int headCommaCount = CountComma(csvHead!);
            tempwriter.WriteLine(csvHead);
            while ((line = reader.ReadLine()) != null)
            {
                // test the line is break or not
                if(CountComma(line) < headCommaCount) 
                {
                    var fakeLine = string.Empty;
                    while((fakeLine = reader.ReadLine()) != null)
                    {
                        line += fakeLine + '_';
                        if(CountComma(line) >= headCommaCount)
                        {
                            line += "\n\n";
                            break;
                        }
                    }
                }
                tempwriter.WriteLine(line);
            }
            ConsolidateStream();
            DataTrunk = tempreader.ReadToEnd();
            Console.WriteLine("Data end");
            stream.Position = 0;
        }
    }

    private void ParseAle(string path)
    {
        string line = string.Empty;
        using (StreamReader reader = new(path))
        {
            while ((line = reader.ReadLine()) != null)
            {
                if (line.Contains("Heading"))
                {
                    stream.Position = 0;
                    line = reader.ReadLine()!;
                }
                if (line.Contains("Column"))
                {
                    ConsolidateStream();
                    Heading = tempreader.ReadToEnd();
                    Console.WriteLine("Heading end");
                    Console.WriteLine(Heading);
                    stream.Position = 0;
                    line = reader.ReadLine()!;
                }
                if (line.Contains("Data"))
                {
                    ConsolidateStream();
                    Column = tempreader.ReadToEnd();
                    Console.WriteLine("Column end");
                    Console.WriteLine(Column);
                    stream.Position = 0;
                    line = reader.ReadLine()!;
                }
                tempwriter.WriteLine(line);
            }
            ConsolidateStream();
            DataTrunk = tempreader.ReadToEnd();
            Console.WriteLine("Data end");
            stream.Position = 0;
        }
    }

    private void ConsolidateStream()
    {
        tempwriter.Flush();
        stream.Position = 0;
    }

    void CsvHelperTest()
    {

        // foreach (DataRow row in dt.Rows)
        // {
        //     foreach (DataColumn col in dt.Columns)
        //     {
        //         Console.Write(row[col] + " ");
        //     }
        //     Console.WriteLine();
        // }
        // write data to ale

        dt.Columns.Add("Fuck", typeof(string));
        DataRow[] rows = dt.Select("Name LIKE '%wav%'");

        foreach (DataRow row in rows)
        {
            // Set value of NewColumn column to "K"
            row["Fuck"] = "K";
        }
        var query = from row in dt.AsEnumerable()
                    where row.Field<string>("Circled") == "N"
                    select row;

        // var col = dt.Columns;
    }

    private void GenerateDataTable()
    {
        // clean the empty lines
        string lines = RemoveEmptyLines(Column + DataTrunk);
        using(StreamWriter _ = new("./temp.csv"))
        {
            _.WriteLine(lines);
        }
        tempwriter.WriteLine(lines);
        ConsolidateStream();

        // start to edit the ale
        using(StreamReader _ = new("./temp.csv"))
        using (CsvReader r = new(_, (parserType == "ale") ? aleConfig : config))
        using (var dr = new CsvDataReader(r))
        {
            dt.Load(dr);
        }
    }

    public void WriteAle(string path)
    {
        using (StreamWriter aleWriter = new(path))
        {
            if (parserType == "ale")
            {
                aleWriter.WriteLine("Heading");
                aleWriter.WriteLine(Heading);
                aleWriter.WriteLine("Column");
            }
            var headerList = dt.Columns.Cast<DataColumn>().Select(column => column.ColumnName);
            var header = string.Join((parserType == "ale") ?aleConfig.Delimiter:config.Delimiter, headerList);
            aleWriter.WriteLine(header);
            if (parserType == "ale")
            {
                aleWriter.WriteLine("Data");
            }
            foreach (DataRow row in dt.Rows)
            {
                IEnumerable<string> fields = row.ItemArray.Select(field => field.ToString());
                aleWriter.WriteLine(string.Join((parserType == "ale") ?aleConfig.Delimiter:config.Delimiter, fields));
            }
        }
    }

    private string RemoveEmptyLines(string toProcess)
    {
        return Regex.Replace(toProcess, @"\n\n", string.Empty, RegexOptions.Multiline);
    }
    
    private string RemoveExtraReturns(string toProcess)
    {
        string input = "dUBITS=26022200\n\ndSCENE=220226\n\ndTAKE=019\n\ndTAPE=RECORDING\n\ndFRAMERATE=25.000ND\n\ndSPEED=025.000-NDF\n\ndTRK3=BOOM\n\ndNOTE=Good Take\n";
        string pattern = "\"([^\"]|\")*\"";
        string output = Regex.Replace(input, pattern, m => m.Value.Replace("\n", ""));
        return output;

    }

    int CountComma(string line)
    {
        bool inQuote = false;
        int count = line.Count(c=>
        {
            if (c == '\"')
            {
                inQuote = !inQuote;
            }
            return c == ',' && !inQuote;
        }
        );
        return count;
    }

    public void Dispose()
    {
        tempreader.Close();
        tempwriter.Close();
        stream.Close();
        Console.WriteLine("done");
    }
}