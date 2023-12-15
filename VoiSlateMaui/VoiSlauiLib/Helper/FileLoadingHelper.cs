using System.Data;
using System.Text.RegularExpressions;
using ATL;
using VideoTimecode;
using VoiSlauiLib.Models;
using VoiSlauiLib.Utilities;

namespace VoiSlauiLib.Helper;

public class FileLoadingHelper
{
    public static FileLoadingHelper Instance = new FileLoadingHelper();

    public List<FileInfo> WavList = new();

    public List<SlateLogItem> LogList = new();
    public double writingProgress = 0.0;

    public AlePaser Ale;
    FileInfo alePath;
    private EnumerableRowCollection<DataRow> _queryVideo;
    private EnumerableRowCollection<DataRow> _queryBwf;
    private EnumerableRowCollection<DataRow> _queryTimeline;

    public int GetBwf(string folderPath) //method to list all .wav files in given folder
    {
        DirectoryInfo rootDir = new DirectoryInfo(folderPath); //create directory object for given folder path
        var rootFiles = rootDir.GetFiles("*", SearchOption.AllDirectories);
        var files = rootFiles.Where(s => (s.Extension.ToLower() == ".wav")).ToList<FileInfo>(); //get all .wav files in directory
        
        foreach (FileInfo file in files) //loop through each .wav file
        {
            WavList.Add(file); //add file to list of .wav files
        }
        return MappingRecordFileInfo();
    }

    public void GetLogs(string jsonPath) //method to list all .wav files in given folder
    {
        LogList.Clear();
        string jsonText = File.ReadAllText(jsonPath);
        var list = Newtonsoft.Json.Linq.JArray.Parse(jsonText);
        List<Task> loadLog = new();
        foreach (var item in list)
        {
            Task creatNewLog()
            {
                string scn = item["scn"]!.ToString();
                string sht = item["sht"]!.ToString();
                int tk = int.Parse(item["tk"]!.ToString());
                string filenamePrefix = item["filenamePrefix"]!.ToString();
                string filenameLinker = item["filenameLinker"]!.ToString();
                int filenameNum = int.Parse(item["filenameNum"]!.ToString());

                string tkNote = item["tkNote"]!.ToString();
                string shtNote = item["shtNote"]!.ToString();
                string scnNote = item["scnNote"]!.ToString();
                TkStatus okTk = (TkStatus)Enum.Parse(typeof(TkStatus), item["okTk"]!.ToString());
                ShtStatus okSht = (ShtStatus)Enum.Parse(typeof(ShtStatus), item["okSht"]!.ToString());
                // to parse the shot notes and track list
                var shtNotePreParse = shtNote.Split('<');
                shtNote = shtNotePreParse[0];
                List<String> trackList = new List<String>();
                if (shtNotePreParse.Length > 1)
                {
                    shtNotePreParse = shtNotePreParse.Skip(1).ToArray();
                    foreach (var element in shtNotePreParse)
                    {
                        // iterate through the remaining elements
                        trackList.Add(element.Replace("/>", "")); // strip "/>" and add to trackList
                    }
                }


                SlateLogItem newLogItem = new SlateLogItem(
                    scn,
                    sht,
                    tk,
                    filenamePrefix,
                    filenameLinker,
                    filenameNum,
                    tkNote,
                    shtNote,
                    scnNote,
                    trackList,
                    okTk,
                    okSht);
                LogList.Add(newLogItem);
                return Task.CompletedTask;
            }

            loadLog.Add(creatNewLog()); 
        } 
        Task.WhenAll(loadLog).ContinueWith(t =>
        {
            MappingRecordFileInfo(); 
            MapppingAleInfo();
            return Task.CompletedTask;
        } );
    }

    int MappingRecordFileInfo()
    {
        if (LogList.Count == 0 || WavList.Count == 0)
            return 0;
        List<Task> mappingTasks = new();
        int mappedCount = 0;
        foreach (var item in LogList)
        {
            Task MapItemToBwf()
            {
                var name = item.fileName;
                var query =
                    from info in WavList
                    where info.Name.Contains(name)
                    orderby info.Name
                    select info;
                query = FindAnyPossible(query, item);
                var files = query.ToList();
                if (files != null && files.Count != 0) mappedCount++;
                item.bwfList = files;
                try
                {
                    GetBwfTimecode(files, item);
                }
                catch
                {
                    item.bwfSynced = false;
                }

                return Task.CompletedTask;
            }

            mappingTasks.Add(MapItemToBwf());
        }
        Task.WhenAll(mappingTasks);
        return mappedCount;
    }

    private static void GetBwfTimecode(List<FileInfo> files, SlateLogItem item)
    {
        Timecode invalidTime = new(0, FrameRate.FrameRate24);
        Track bwf = new Track(files[0].FullName);
        BwfTimeCode thisBwfTC = new(bwf);
        item.startTc = thisBwfTC.StartTc ?? invalidTime;
        item.endTc = thisBwfTC.EndTc ?? invalidTime;
        item.fileLength = thisBwfTC.DurationTc ?? invalidTime;
        item.ubits = thisBwfTC.Ubits;
        item.bwfSynced = true;
    }

    private IOrderedEnumerable<FileInfo> FindAnyPossible(IOrderedEnumerable<FileInfo> query, SlateLogItem item)
    {
        // find if without linker, is there any possible file
        if (!query.Any())
        {
            Regex ambigReg = new($".*{item.filenamePrefix}.*{item.filenameNum}");
            query =
                from info in WavList
                where ambigReg.IsMatch(info.Name)
                orderby info.Name
                select info;
        }
        // For sound devices
        if (!query.Any())
        {
            Regex ambigReg = new($".*{item.filenamePrefix}.*{item.filenameNum.ToString().PadLeft(2, '0')}");
            query =
                from info in WavList
                where ambigReg.IsMatch(info.Name)
                orderby info.Name
                select info;
        }
        // find if there is any file named match the scene-shot-take or scene-take
        if (!query.Any())
        {
            var ambigRegA = new Regex($".*{item.scn}.*{item.sht}.*{item.tk}");
            var ambigRegB = new Regex($".*{item.scn}.*{item.tk}");
            query =
                from info in WavList
                where ambigRegA.IsMatch(info.Name) || ambigRegB.IsMatch(info.Name)
                orderby info.Name
                select info;
        }

        return query;
    }

    public void GetAle(string path)
    {
        alePath = new(path);
        Ale = new AlePaser(alePath);
        // linq, fild the "resolution" in dt, if it is not empty, "FileType" equal to "A"
        _queryTimeline = from row in Ale.dt.AsEnumerable()
            where row.Field<string>("Resolution") != "" 
                  && row.Field<string>("Clip Directory") == ""
            select row;
        _queryBwf = from row in Ale.dt.AsEnumerable()
            where row.Field<string>("Resolution") == "" 
                  && row.Field<string>("File Name").Contains(".wav")
            select row;
        _queryVideo = from row in Ale.dt.AsEnumerable()
            where row.Field<string>("Resolution") != ""
                  && row.Field<string>("Clip Directory") != ""
            orderby row.Field<string>("Start TC")
            select row;
        Ale.dt.AcceptChanges();
        MapppingAleInfo();
    }

    void MapppingAleInfo()
    {
        if (LogList.Count == 0 || Ale == null) return;
        foreach (var item in LogList)
        {
            Task.Run(() =>
            {
                BwfTimeCode bwfTime = new(item.startTc, item.endTc);
                var query = _queryVideo.Where(info =>
                {
                    var startTime = info.Field<string>("Start TC");
                    var endTime = info.Field<string>("End TC");
                    BwfTimeCode videoTime = new BwfTimeCode(startTime, endTime, bwfTime.FramRate);
                    return Comparor.IsTimeCrossed(bwfTime, videoTime);
                });
                item.videoList = query;
            });
        }
    }   

    public async Task WriteMetaData()
    {
        double writedCount = 0.0;
        double writeProg = 0.0;
        double logAmount = LogList.Sum(log => log.bwfList.Count);

        Task WriteSingleBwf(FileInfo bwf, SlateLogItem item)
        {
            Track tr = new(bwf.FullName);
            var originalNote = "";
            try
            {
                originalNote = tr.AdditionalFields["ixml.Note"];
            }
            catch
            {
                originalNote = "";
            }

            var editedNote = item.scnNote + "," + item.shtNote + originalNote;
            WriteAdditional(tr, "ixml.SCENE", item.scn + "-" + item.sht);
            WriteAdditional(tr, "ixml.TAKE", item.tk.ToString());
            WriteAdditional(tr, "ixml.NOTE", editedNote);
            WriteAdditional(tr, "ixml.CIRCLED", (item.okTk == TkStatus.ok) ? "TRUE" : "FALSE");
            WriteAdditional(tr, "ixml.TAKE_TYPE", (item.okTk == TkStatus.bad) ? "NO_GOOD" : "DEFAULT");
            WriteAdditional(tr, "ixml.WILD_TRACK", (item.tkNote.Contains("wild")) ? "TRUE" : "FALSE");
            // WriteTrackList(tr, item.trackList);
            tr.Description = item.tkNote;
            tr.Title = item.shtNote;
            tr.Save();

            writedCount++;
            writeProg = writedCount / logAmount;
            ProgressBlock.Instance.OnProgress(writeProg);
            return Task.CompletedTask;
        }

        List<Task> taskList = new();
        foreach (var item in LogList)
        {
            foreach (var bwf in item.bwfList)
            {
                taskList.Add(WriteSingleBwf(bwf, item));
            }
        }

        await Task.WhenAll(taskList);
    }

    private void WriteTrackList(Track tr, List<string>? trackList)
    {
        if(trackList == null) return;
        if(trackList.Count == 0) return; // check if trackList has no items
        foreach (string track in trackList)
        {
            WriteAdditional(tr, "skj", track);
        }
    }

    void WriteAdditional(Track tr, string tag, string content)
    {
        if (tr.AdditionalFields.ContainsKey(tag)) tr.AdditionalFields[tag] = content;
        else tr.AdditionalFields.Add(tag, content);
    }

    public void WriteAleData(string p)
    {
        if (!Ale.dt.Columns.Contains("Flags")) Ale.dt.Columns.Add("Flags");
        if (!Ale.dt.Columns.Contains("Good Take")) Ale.dt.Columns.Add("Good Take");
        if (!Ale.dt.Columns.Contains("Description")) Ale.dt.Columns.Add("Description");
        if (!Ale.dt.Columns.Contains("Scene")) Ale.dt.Columns.Add("Scene");
        if (!Ale.dt.Columns.Contains("Shot")) Ale.dt.Columns.Add("Shot");
        if (!Ale.dt.Columns.Contains("Take")) Ale.dt.Columns.Add("Take");
        if (!Ale.dt.Columns.Contains("Environment")) Ale.dt.Columns.Add("Environment");
        foreach (DataColumn col in Ale.dt.Columns) col.ReadOnly = false;
        foreach (var item in LogList)
        {
            foreach (var video in item.videoList)
            {
                video["Scene"] = item.scn;
                video["Shot"] = item.sht;
                video["Take"] = item.tk;
                video["Flags"] = (item.okSht == ShtStatus.notChecked) ? "" 
                                    :(item.okSht == ShtStatus.nice) ? "Blue"
                                    : "Green";
                video["Good Take"] = (item.okSht == ShtStatus.notChecked) ? "":"1";
                video["Description"] = item.shtNote;
                video["Environment"] = item.scnNote;
            }
        }
        Ale.dt.AcceptChanges();
        if(!Directory.Exists(p)) Directory.CreateDirectory(p);
        var fileName = Path.GetFileNameWithoutExtension(alePath.Name);
        fileName = fileName + "_" + fileName.GetHashCode().ToString("x").Substring(0, 4);
        string path = Path.Combine(p, fileName + alePath.Extension);
        
        Ale.WriteAle(path);
    }

}
