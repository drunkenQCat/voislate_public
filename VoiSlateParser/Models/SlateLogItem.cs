using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using VideoTimecode;

using VoiSlateParser.Helper;
// ReSharper disable InconsistentNaming

namespace VoiSlateParser.Models;

public enum TkStatus
{
    notChecked = 0,
    ok = 1,
    bad = 2
}

public enum ShtStatus
{
    notChecked = 0,
    ok = 1,
    nice = 2
}

public class SlateLogItem
{
    public SlateLogItem(
        string scn,
        string sht,
        int tk,
        string filenamePrefix,
        string filenameLinker,
        int filenameNum,
        string tkNote,
        string shtNote,
        string scnNote,
        List<string> trackList,
        TkStatus okTk = TkStatus.notChecked,
        ShtStatus okSht = ShtStatus.notChecked
        )
    {
        this.scn = scn;
        this.sht = sht;
        this.tk = tk;
        this.filenamePrefix = filenamePrefix;
        this.filenameLinker = filenameLinker;
        this.filenameNum = filenameNum;
        this.tkNote = tkNote;
        this.shtNote = shtNote;
        this.scnNote = scnNote;
        this.trackList = trackList;
        this.okTk = okTk;
        this.okSht = okSht;
        this.bwfSynced = false;
        this.startTc = new Timecode(0,FrameRate.FrameRate24);
        this.endTc = new Timecode(0,FrameRate.FrameRate24);
        this.fileLength = new Timecode(0,FrameRate.FrameRate24);
        this.ubits = "00000000";
        this.bwfList = new();
    }

    public string fileName => filenamePrefix + filenameLinker + filenameNum.ToString().PadLeft(3,'0');
    public string scn { get; set; }
    public string sht { get; set; }
    public int tk { get; set; }
    public string filenamePrefix { get; set; }
    public string filenameLinker { get; set; }
    public int filenameNum { get; set; }
    public string tkNote { get; set; }
    public string shtNote { get; set; }
    public string scnNote { get; set; }
    public List<string>? trackList{ get; set;}

    // public string scnNote 
    // {
    //     get => shtNote;
    //     set => scnNote = EncodingHelper.ConvertUtfToIso(value);
    // }

    public TkStatus okTk { get; set; }
    public ShtStatus okSht { get; set; }
    
    public Timecode startTc { get; set; }
    public string startTcString => startTc.ToString();
    public Timecode endTc { get; set; }
    public string endTcString => endTc.ToString();
    public Timecode fileLength { get; set; }
    public string fileLengthString => fileLength.ToString();
    
    public List<FileInfo> bwfList { get; set; }
    public EnumerableRowCollection<DataRow> videoList { get; set; }
    public List<string?> videoListNames => (videoList != null)? videoList.Select(row => row["File Name"].ToString()).ToList():new();
    public string ubits { get; set; }

    public bool bwfSynced { get; set; }
    public bool videoSynced { get; set; }

    public bool Contains(string filterText)
    {
        if (scn.Contains(filterText)) return true;
        if (sht.Contains(filterText)) return true;
        if (tkNote.Contains(filterText)) return true;
        if (shtNote.Contains(filterText)) return true;
        if (scnNote.Contains(filterText)) return true;
        if (fileName.Contains(filterText)) return true;
        if (bwfList != null)
        {
            if (BwfContainsFileter(filterText)) return true;
        }
        return false;
    }

    private bool BwfContainsFileter(string filterText)
    {
    // a function to find if any items in bwfList.Name contains fileterText
    // if so, return true, else false.
    // if bwfList is null, return true.
    // if bwfList is empty, return true.
    // if bwfList is not empty, return true if any item contains filterText.
        if (bwfList == null)
        {
            {
                return true;
            }
        }

        if (bwfList != null)
        {
            foreach (var bwf in bwfList)
            {
                if (bwf.Name.Contains(filterText))
                {
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }


}