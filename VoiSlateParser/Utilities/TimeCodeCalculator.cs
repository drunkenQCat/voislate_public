using System;
using ATL;
using VideoTimecode;
using VoiSlateParser.Utilities;


namespace VoiSlateParser.Utilities;

internal class Comparor 
{
    static public bool IsTimeCrossed(BwfTimeCode itemA, BwfTimeCode itemV)
    {
        if (itemA.StartTc == null || itemV.StartTc == null) return false;
        bool isVedGreaterThanAst = itemV.EndTc.ToTimeSpan().CompareTo(itemA.StartTc.ToTimeSpan()) < 0;
        bool isAedGreaterThanVst = itemA.EndTc.ToTimeSpan().CompareTo(itemV.StartTc.ToTimeSpan()) < 0;
        bool isCrossed = !(isAedGreaterThanVst || isVedGreaterThanAst);
        if (isCrossed)
        {
            Console.WriteLine($"Timecode {itemA.StartTc} and {itemV.StartTc} are crossed");
        }
        return isCrossed;
    }
}

public class BwfTimeCode
{
    public FrameRate? FramRate;
    public Timecode? StartTc;
    public Timecode? EndTc;
    public Timecode? DurationTc;
    public string Ubits;

    public BwfTimeCode(Track bwf)
    {
        FramRate = GetFrameRate(bwf);
        StartTc = GetStartTc(bwf);
        EndTc = GetEndTc(bwf);
        DurationTc = GetDurationTc();
        Ubits = GetUbits(bwf);
    }

    private Timecode GetDurationTc()
    {
        return  new(EndTc.ToTimeSpan() - StartTc.ToTimeSpan(), FramRate);
    }

    public BwfTimeCode(Timecode st, Timecode ed)
    {
        this.StartTc = st;
        this.EndTc = ed;
        this.FramRate = st.FrameRate;
    }
    public BwfTimeCode(string st, string ed, FrameRate fps)
    {
        this.StartTc = new(st, fps);
        this.EndTc = new(ed, fps);
        this.FramRate = fps;
    }

    Timecode? GetStartTc(Track bwf)
    {
        if (bwf.AdditionalFields.ContainsKey("bext.timeReference")){
            long smpls = long.Parse(bwf.AdditionalFields["bext.timeReference"]);
            var secondsFromMidnight = (int)(smpls / (long)bwf.SampleRate); //convert the right value to int
            TimeSpan timeSpan = TimeSpan.FromSeconds(secondsFromMidnight);
            var startTc = new Timecode(timeSpan, FramRate);
            return startTc;
        }
        else
        {
            return null;
        }
    }
    
    Timecode? GetEndTc(Track bwf)
    {
        if (StartTc == null) return null;
        Timecode? endTc;
        var druationSeconds = bwf.Duration;
        var endSpan = StartTc.ToTimeSpan() + TimeSpan.FromSeconds(druationSeconds);
        endTc = new Timecode(endSpan, FramRate);
        return endTc;
    }
    
    FrameRate? GetFrameRate(Track bwf)
    {
        var r = bwf.AdditionalFields["ixml.SPEED.TIMECODE_RATE"];
        if (r == null) return null;
        bool dropFrame = bwf.AdditionalFields["ixml.SPEED.TIMECODE_FLAG"] == "DF";
        var _ = r.Split('/');
        // the TIMECODE_RATE is always presented as X/Y. so it's necessary to translate it to the format we usually uses
        double rateDouble = double.Parse(_[0]) 
                            / double.Parse(_[1]);
        var (rateCount, rateName, dropCount) = RateNameParser(rateDouble, dropFrame);

        FrameRate rate = new(){ Rate = rateCount, Name = rateName, DropFramesCount = dropCount}; 
        return rate;
    }

    private (double rateCount, string rateName, int dropCount) RateNameParser(double rateDouble, bool dropFrame)
    {
        double rateCount;
        string rateName;
        int dropCount = 0;
        if ((_isInteger(rateDouble)))
        {
            rateCount = rateDouble;
            rateName = string.Format("{00:f}", rateDouble);
        }
        else
        {
            if ((rateDouble > 24))
            {
                // 29.97 or 59.94 fps
                var s = string.Format("{00:f2}", rateDouble);
                rateCount = float.Parse(s);
                // for 59.94 fps, dropframe is 4
                dropCount = (dropFrame && rateDouble > 30) ? 4 : 2;
                rateName = dropFrame ? s + " DF" : s + " NDF";
            }
            else
            {
                // 23.976 fps
                var s = string.Format("{00:f3}", rateDouble);
                rateCount = float.Parse(s);
                rateName = s;
            }
        }

        return (rateCount, rateName, dropCount);
    }

    string GetUbits(Track bwf)
    {
        var Ubits = bwf.AdditionalFields["ixml.UBITS"];
        if (Ubits == null) return null;
        return Ubits;
    }

    private bool _isInteger(double num)
    {
        double eps = 1e-10;
        return num - Math.Floor(num) < eps;
    }
}